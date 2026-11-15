CREATE OR REPLACE PROCEDURE add_json_document
(
  INOUT p_document_id BIGINT,
  p_document_type_id SMALLINT,
  p_external_ref VARCHAR(30),
  p_tags_json_array VARCHAR(200),
  p_json_document CLOB(2M)
)
BEGIN
  DECLARE v_add_document_role VARCHAR(30);
  DECLARE v_is_duplicate_external_ref_blocked BOOLEAN;
  DECLARE v_is_valid_json BOOLEAN;
  DECLARE v_partition_num SMALLINT;
  DECLARE v_is_external_ref BOOLEAN;

  -- Look up document type
  SET (v_add_document_role, v_is_duplicate_external_ref_blocked) =
    (SELECT add_document_role, is_duplicate_external_ref_blocked FROM document_type WITH CS);

  -- Signal an exception when the user is not authorised
  IF VERIFY_ROLE_FOR_USER(SESSION_USER, v_add_document_role) = 0 THEN
    SIGNAL SQLSTATE 'DS401' SET MESSAGE_TEXT = 'Not authorised';
  END IF;

  -- Validate tags JSON array
  IF p_tags_json_array IS NOT NULL THEN
    IF NOT is_json_array(p_tags_json_array) THEN
      SIGNAL SQLSTATE 'DS202' SET MESSAGE_TEXT = 'Invalid JSON array';
    END IF;
  END IF;

  -- Validate JSON document
  SET v_is_valid_json = is_json_document(p_json_document);
  IF NOT v_is_valid_json AND is_invalid_json_blocked() THEN
    SIGNAL SQLSTATE 'DS201' SET MESSAGE_TEXT = 'Invalid JSON document';
  END IF;

  -- Check for existing external reference, and block if duplicates not allowed
  IF p_external_ref IS NOT NULL THEN
    SET v_is_external_ref =
      (
        SELECT TRUE FROM external_reference WHERE external_ref = p_external_ref AND external_ref_type_id = p_document_type_id
        WITH RR USE AND KEEP UPDATE LOCKS
      );
    SET v_is_external_ref = COALESCE(v_is_external_ref, FALSE);
    IF v_is_external_ref AND v_is_duplicate_external_ref_blocked THEN
      SIGNAL SQLSTATE 'DS301' SET MESSAGE_TEXT = 'Duplicate EXTERNAL_REF';
    END IF;
  END IF;

  -- Set document identifier (if unset) and partition number
  IF p_document_id IS NULL THEN
    SET p_document_id = NEXT VALUE FOR document_id;
  END IF;
  SET v_partition_num = get_partition_num(p_document_id);

  -- Perform updates
  BEGIN ATOMIC
    -- Insert external reference if supplied, and not already done
    IF p_external_ref IS NOT NULL AND NOT v_is_external_ref THEN
      INSERT INTO external_reference(external_ref, external_ref_type_id) VALUES (p_external_ref, p_document_type_id);
    END IF;

    -- Insert the index row
    INSERT INTO document_index
    (
      document_id, partition_num, document_type_id, inserted_utc_ts, is_valid_json, external_ref
    )
    VALUES
      (
        p_document_id,
        v_partition_num,
        p_document_type_id,
        CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
        v_is_valid_json,
        p_external_ref
      );

    -- Insert JSON row
    INSERT INTO document_json(document_id, partition_num, json_document)
    VALUES
      (p_document_id, v_partition_num, p_json_document);

    -- Insert JSON tags
    IF p_tags_json_array IS NOT NULL THEN
      FOR r AS
        SELECT
          t.tag_id, p.value
        FROM
          TABLE(get_json_tags(p_tags_json_array)) AS p
            LEFT OUTER JOIN
          document_type_tag AS t
            ON
              t.tag = p.tag AND
              t.document_type_id = p_document_type_id
      DO
        IF r.tag_id IS NULL THEN
          SIGNAL SQLSTATE 'DS302' SET MESSAGE_TEXT = 'Invalid tag';
        END IF; 
        INSERT INTO document_tag(document_id, document_type_id, tag_id, value, inserted_utc_ts)
        VALUES
          (p_document_id, p_document_type_id, r.tag_id, r.value, CURRENT_TIMESTAMP - CURRENT_TIMEZONE);
      END FOR;
    END IF;
    
    -- Add audit entry.
    CALL log_action('ADD_DOCUMENT', p_document_id, p_document_type_id, NULL, NULL);
  END;
END@

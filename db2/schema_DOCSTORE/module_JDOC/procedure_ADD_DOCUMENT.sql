ALTER MODULE jdoc
ADD PROCEDURE add_document
(
  INOUT p_document_id BIGINT,
  p_document_type_id SMALLINT,
  p_external_ref VARCHAR(30),
  p_tags_json_array VARCHAR(2000),
  p_json_document CLOB(2M)
)
BEGIN
  DECLARE v_check BOOLEAN;
  DECLARE v_is_valid_json BOOLEAN;
  DECLARE v_partition_num SMALLINT;
  DECLARE v_is_new_external_ref BOOLEAN;

  -- Check user is authorised to add document
  SET v_check = private.is_adder(p_document_type_id);

  -- Validate JSON document
  SET v_is_valid_json = private.is_json_document(p_json_document);
  IF NOT v_is_valid_json AND private.is_invalid_json_blocked() THEN
    SIGNAL SQLSTATE 'DS201' SET MESSAGE_TEXT = 'Invalid JSON document';
  END IF;

  -- Validate tags JSON array
  IF p_tags_json_array IS NOT NULL THEN
    IF NOT private.is_json_array(p_tags_json_array) THEN
      SIGNAL SQLSTATE 'DS202' SET MESSAGE_TEXT = 'Invalid JSON array';
    END IF;
  END IF;

  -- Check for whether supplied external reference is new, and reject disallowed duplicate
  IF p_external_ref IS NOT NULL THEN
    SET v_is_new_external_ref = private.is_new_external_ref(p_document_type_id, p_external_ref);
  END IF;

  -- Set document identifier (if unset) and partition number
  IF p_document_id IS NULL THEN
    SET p_document_id = NEXT VALUE FOR document_id;
  END IF;
  SET v_partition_num = private.get_partition_num(p_document_id);

  -- Perform updates
  BEGIN ATOMIC
    -- Insert external reference if supplied, and not already done
    IF p_external_ref IS NOT NULL AND v_is_new_external_ref THEN
      INSERT INTO external_reference(external_ref, document_type_id) VALUES (p_external_ref, p_document_type_id);
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

    -- Build all indexes
    FOR r AS
      SELECT index_id FROM json_index WHERE document_type_id = p_document_type_id AND NOT is_delete_pending WITH CS
    DO
      CALL private.add_index_entry(p_document_id, r.index_id, p_json_document);
    END FOR;
    
      -- Insert JSON tags
    IF p_tags_json_array IS NOT NULL THEN
      FOR r AS
        SELECT
          t.tag_id, t.is_value_required, t.is_domain_checked, p.value, v.domain_value
        FROM
          TABLE(get_tags(p_tags_json_array)) AS p
            LEFT OUTER JOIN
          tag AS t
            ON
              t.tag = p.tag AND
              t.document_type_id = p_document_type_id AND
              t.tag_type = 'DOCUMENT'
            LEFT OUTER JOIN
          tag_domain_value AS v
            ON
              v.tag_id = t.tag_id AND
              v.document_type_id = p_document_type_id AND
              v.domain_value = p.value
      DO
        IF r.tag_id IS NULL THEN
          SIGNAL SQLSTATE 'DS204' SET MESSAGE_TEXT = 'Invalid document tag';
        END IF; 
        IF r.is_value_required AND r.value IS NULL THEN
          SIGNAL SQLSTATE 'DS206' SET MESSAGE_TEXT = 'Tag requires a value';
        END IF; 
        IF NOT r.is_value_required AND r.value IS NOT NULL THEN
          SIGNAL SQLSTATE 'DS207' SET MESSAGE_TEXT = 'Tag does not permit any value';
        END IF; 
        IF NOT r.is_domain_checked AND r.domain_value IS NOT NULL THEN
          SIGNAL SQLSTATE 'DS208' SET MESSAGE_TEXT = 'Tag value is not in value domain';
        END IF; 
        INSERT INTO document_tag(document_id, document_type_id, tag_id, inserted_utc_ts, value)
        VALUES
          (p_document_id, p_document_type_id, r.tag_id, CURRENT_TIMESTAMP - CURRENT_TIMEZONE, r.value);
      END FOR;
    END IF;
  
    -- Add audit entry
    CALL private.log_action('ADD_DOCUMENT', p_document_id, p_document_type_id, NULL, NULL);
  END;
END@

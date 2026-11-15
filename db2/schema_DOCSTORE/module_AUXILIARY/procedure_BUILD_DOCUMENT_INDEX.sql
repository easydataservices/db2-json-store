ALTER MODULE auxiliary
ADD PROCEDURE build_document_index(p_document_id BIGINT, p_index_id SMALLINT)
BEGIN
  DECLARE v_partition_num SMALLINT;
  DECLARE v_document_type_id SMALLINT;
  DECLARE v_json_path VARCHAR(1000);
  DECLARE v_value VARCHAR(60);

  -- Retrieve document details
  SET (v_partition_num, v_document_type_id) =
    (SELECT partition_num, document_type_id FROM document_index WHERE document_id = p_document_id WITH CS);

  -- Retrieve index JSON path
  SET v_json_path =
    (
      SELECT
        json_path
      FROM
        json_index
      WHERE
        index_id = p_index_id AND document_type_id = v_document_type_id AND NOT is_delete_pending
      WITH CS
    );
  IF v_json_path IS NULL THEN
    SIGNAL SQLSTATE 'DS203' SET MESSAGE_TEXT = 'Index does not exist';
  END IF;

  -- If the index entry does not already exist then add entry
  IF NOT EXISTS (SELECT * FROM json_index_value WHERE index_id = p_index_id AND document_id = p_document_id WITH RR) THEN
    SET v_value =
      (
        SELECT
          JSON_VALUE(json_document, v_json_path RETURNING VARCHAR(20))
        FROM
          document_json
        WHERE
          partition_num = v_partition_num AND document_id = p_document_id
        WITH CS
      );
    IF v_value IS NOT NULL THEN
      INSERT INTO json_index_value(index_id, document_id, value)
      VALUES
        (p_index_id, p_document_id, v_value);
    END IF;
  END IF;
END@

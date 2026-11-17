ALTER MODULE private
ADD PROCEDURE add_index_bigint_entry
(
  p_document_id BIGINT, p_index_id SMALLINT, p_partition_num SMALLINT, p_json_path VARCHAR(1000)
)
BEGIN
  DECLARE v_value BIGINT;

  -- Shortcut exit if index entry already exists
  IF EXISTS (SELECT * FROM json_bigint_index_value WHERE index_id = p_index_id AND document_id = p_document_id WITH RR) THEN
    RETURN;
  END IF;

  -- Add entry from JSON value (if found)
  SET v_value =
    (
      SELECT
        JSON_VALUE(json_document, p_json_path RETURNING BIGINT)
      FROM
        document_json
      WHERE
        partition_num = p_partition_num AND document_id = p_document_id
      WITH CS
    );
  IF v_value IS NOT NULL THEN
    INSERT INTO json_bigint_index_value(index_id, document_id, value)
    VALUES
      (p_index_id, p_document_id, v_value);
  END IF;
END@

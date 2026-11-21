ALTER MODULE docuser
ADD FUNCTION get_json_bigint_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  )
BEGIN
  DECLARE v_index_id SMALLINT;

  -- Validate JSON path
  IF NOT private.is_json_path(p_json_path) THEN
    SIGNAL SQLSTATE 'DS202' SET MESSAGE_TEXT = 'Invalid JSON path';
  END IF;

  -- Retrieve index details
  SET v_index_id =
    (
      SELECT
        index_id
      FROM
        json_index
      WHERE
        document_type_id = p_document_type_id AND
        json_path = private.tidy_json_path(p_json_path) AND
        value_data_type = 'BIGINT' AND
        NOT is_build_pending AND
        NOT is_delete_pending
      WITH CS
    );

  -- If no suitable index exists then pipe results from documents; otherwise from the index 
  IF v_index_id IS NULL THEN
    FOR r AS
      SELECT
        document_id, JSON_VALUE(json_document, p_json_path RETURNING BIGINT) AS value
      FROM
        json_document
      WHERE
        document_type_id = p_document_type_id
      WITH CS
    DO
      IF value IS NOT NULL THEN
        PIPE(r.document_id, r.value);
      END IF;
    END FOR;
  ELSE
    FOR r AS
      SELECT document_id, value FROM json_bigint_index_value WHERE index_id = v_index_id WITH CS
    DO
      PIPE(r.document_id, r.value);
    END FOR;
  END IF;

  -- Return
  RETURN;
END@

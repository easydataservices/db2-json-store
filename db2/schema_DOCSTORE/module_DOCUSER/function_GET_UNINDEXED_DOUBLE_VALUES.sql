ALTER MODULE docuser
ADD FUNCTION get_unindexed_double_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value DOUBLE
  )
BEGIN
  FOR r AS
    SELECT
      document_id, JSON_VALUE(json_document, p_json_path RETURNING DOUBLE) AS value
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
  RETURN;
END@

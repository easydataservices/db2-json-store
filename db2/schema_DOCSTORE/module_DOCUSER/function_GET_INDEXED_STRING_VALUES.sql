ALTER MODULE docuser
ADD FUNCTION get_indexed_string_values(p_index_id SMALLINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    value VARCHAR(1000)
  )
BEGIN
  FOR r AS
    SELECT document_id, value FROM json_string_index_value WHERE index_id = p_index_id WITH CS
  DO
    PIPE(r.document_id, r.value);
  END FOR;
  RETURN;
END@

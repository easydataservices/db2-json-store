ALTER MODULE jindex
ADD FUNCTION get_indexed_string_values_eq(p_index_id SMALLINT, p_value VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value VARCHAR(1000)
  )
BEGIN
  FOR r AS
    SELECT document_id, value FROM json_string_index_value WHERE index_id = p_index_id AND value = p_value WITH CS
  DO
    PIPE(r.document_id, r.value);
  END FOR;
  RETURN;
END@

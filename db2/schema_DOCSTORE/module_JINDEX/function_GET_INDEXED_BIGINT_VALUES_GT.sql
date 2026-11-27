ALTER MODULE jindex
ADD FUNCTION get_indexed_bigint_values_gt(p_index_id SMALLINT, p_value BIGINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  )
BEGIN
  FOR r AS
    SELECT document_id, value FROM json_bigint_index_value WHERE index_id = p_index_id AND value > p_value WITH CS
  DO
    PIPE(r.document_id, r.value);
  END FOR;
  RETURN;
END@

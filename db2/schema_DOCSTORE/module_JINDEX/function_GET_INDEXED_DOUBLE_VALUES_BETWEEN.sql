ALTER MODULE jindex
ADD FUNCTION get_indexed_double_values_between(p_index_id SMALLINT, p_min_value DOUBLE, p_max_value DOUBLE)
  RETURNS TABLE
  (
    document_id BIGINT,
    value DOUBLE
  )
BEGIN
  FOR r AS
    SELECT
      document_id, value
    FROM
      json_double_index_value
    WHERE
      index_id = p_index_id AND value BETWEEN p_min_value AND p_max_value
    WITH CS
  DO
    PIPE(r.document_id, r.value);
  END FOR;
  RETURN;
END@

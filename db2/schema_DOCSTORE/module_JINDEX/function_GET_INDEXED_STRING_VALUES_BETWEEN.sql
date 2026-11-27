ALTER MODULE jindex
ADD FUNCTION get_indexed_string_values_between
(
  p_index_id SMALLINT, p_min_value VARCHAR(1000), p_max_value VARCHAR(1000)
)
  RETURNS TABLE
  (
    document_id BIGINT,
    value VARCHAR(1000)
  )
BEGIN
  FOR r AS
    SELECT
      document_id, value
    FROM
      json_string_index_value
    WHERE
      index_id = p_index_id AND value BETWEEN p_min_value AND p_max_value
    WITH CS
  DO
    PIPE(r.document_id, r.value);
  END FOR;
  RETURN;
END@

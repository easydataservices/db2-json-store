ALTER MODULE info
ADD FUNCTION get_indexes(p_document_type_id SMALLINT)
  RETURNS TABLE
  (
    index_id SMALLINT,
    index_name VARCHAR(30),
    json_path VARCHAR(1000),
    value_data_type VARCHAR(20),
    inserted_utc_ts TIMESTAMP(0),
    is_build_pending BOOLEAN,
    is_delete_pending BOOLEAN
  )
RETURN
  (
    SELECT
      index_id, index_name, json_path, value_data_type, inserted_utc_ts, is_build_pending, is_delete_pending
    FROM
      json_index
    WHERE
      document_type_id = p_document_type_id
    WITH CS
  )@

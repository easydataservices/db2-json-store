ALTER MODULE docuser
ADD FUNCTION usable_index_id(p_document_type_id SMALLINT, p_json_path VARCHAR(1000), p_value_data_type VARCHAR(20))
  RETURNS SMALLINT
BEGIN
  DECLARE v_index_id SMALLINT;

  -- Return matched index (otherwise NULL)
  SET v_index_id =
    (
      SELECT
        index_id
      FROM
        json_index
      WHERE
        document_type_id = p_document_type_id AND
        json_path = private.tidy_json_path(p_json_path) AND
        (value_data_type = p_value_data_type OR p_value_data_type IS NULL) AND
        NOT is_build_pending AND
        NOT is_delete_pending
      WITH CS
    );

  -- Return
  RETURN v_index_id;
END@

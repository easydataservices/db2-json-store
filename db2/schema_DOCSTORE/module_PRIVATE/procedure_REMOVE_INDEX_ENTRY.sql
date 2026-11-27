ALTER MODULE private
ADD PROCEDURE remove_index_entry(p_document_id BIGINT, p_index_id SMALLINT) 
BEGIN
  DECLARE v_value_data_type VARCHAR(20);
  DECLARE v_json_path VARCHAR(1000);
  DECLARE v_value VARCHAR(60);

  -- Retrieve index details
  SET v_value_data_type =
    (SELECT value_data_type FROM json_index WHERE index_id = p_index_id AND NOT is_delete_pending WITH CS);
 
  -- Shortcut exit if the index does not exist
  IF v_value_data_type IS NULL THEN
    RETURN;
  END IF;

  -- Remove the index entry
  CASE v_value_data_type
    WHEN 'BIGINT' THEN DELETE FROM json_bigint_index_value WHERE index_id = p_index_id AND document_id = p_document_id;
    WHEN 'DOUBLE' THEN DELETE FROM json_double_index_value WHERE index_id = p_index_id AND document_id = p_document_id;
    ELSE DELETE FROM json_string_index_value WHERE index_id = p_index_id AND document_id = p_document_id;
  END CASE;
END@

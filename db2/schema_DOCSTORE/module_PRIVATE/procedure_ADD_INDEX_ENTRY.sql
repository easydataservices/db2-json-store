ALTER MODULE private
ADD PROCEDURE add_index_entry(p_document_id BIGINT, p_index_id SMALLINT, p_json_document CLOB(2M)) 
BEGIN
  DECLARE v_value_data_type VARCHAR(20);
  DECLARE v_json_path VARCHAR(1000);
  DECLARE v_value VARCHAR(60);

  -- Retrieve index details
  SET (v_value_data_type, v_json_path) =
    (SELECT value_data_type, json_path FROM json_index WHERE index_id = p_index_id AND NOT is_delete_pending WITH CS);
 
  -- Shortcut exit if the index does not exist
  IF v_value_data_type IS NULL THEN
    RETURN;
  END IF;

  -- Add the index entry
  CASE v_value_data_type
    WHEN 'BIGINT' THEN CALL add_index_bigint_entry(p_document_id, p_index_id, v_json_path, p_json_document);
    WHEN 'DOUBLE' THEN CALL add_index_double_entry(p_document_id, p_index_id, v_json_path, p_json_document);
    ELSE CALL add_index_varchar_entry(p_document_id, p_index_id, v_json_path, p_json_document);
  END CASE;
END@

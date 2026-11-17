ALTER MODULE private
ADD PROCEDURE add_index_entry(p_document_id BIGINT, p_index_id SMALLINT)
BEGIN
  DECLARE v_partition_num SMALLINT;
  DECLARE v_value_data_type VARCHAR(20);
  DECLARE v_json_path VARCHAR(1000);
  DECLARE v_value VARCHAR(60);

  -- Retrieve document details
  SET v_partition_num =
    (SELECT partition_num FROM document_index WHERE document_id = p_document_id AND deleted_utc_ts IS NULL WITH CS);

  -- Retrieve index details
  SET (v_value_data_type, v_json_path) =
    (SELECT value_data_type, json_path FROM json_index WHERE index_id = p_index_id AND NOT is_delete_pending WITH CS);
 
  -- Shortcut exit if the document or index does not exist
  IF v_partition_num IS NULL OR v_value_data_type IS NULL THEN
    RETURN;
  END IF;

  -- Add the index entry
  CASE v_value_data_type
    WHEN 'BIGINT' THEN CALL add_index_varchar_entry(p_document_id, p_index_id, v_partition_num, v_json_path);
    WHEN 'DOUBLE' THEN CALL add_index_double_entry(p_document_id, p_index_id, v_partition_num, v_json_path);
    ELSE CALL add_index_varchar_entry(p_document_id, p_index_id, v_partition_num, v_json_path);
  END CASE;
END@

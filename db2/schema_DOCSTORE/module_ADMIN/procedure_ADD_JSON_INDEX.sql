ALTER MODULE admin
ADD PROCEDURE add_json_index
(
  p_index_name VARCHAR(30),
  p_document_type_id SMALLINT,
  p_json_path VARCHAR(1000),
  p_value_data_type VARCHAR(20),
  OUT p_index_id SMALLINT
)
  AUTONOMOUS
BEGIN
  DECLARE v_utc_ts TIMESTAMP(0);

  -- Set UTC time
  SET v_utc_ts = CURRENT_TIMESTAMP - CURRENT_TIMEZONE;

  -- Validate JSON path
  IF NOT private.is_json_path(p_json_path) THEN
    SIGNAL SQLSTATE 'DS202' SET MESSAGE_TEXT = 'Invalid JSON path';
  END IF;

  -- Calculate new index identifier
  SET p_index_id = (SELECT MAX(index_id) FROM json_index WITH RR);
  SET p_index_id = COALESCE(p_index_id, 0) + 1;

  -- Perform updates
  BEGIN ATOMIC
    INSERT INTO json_index(index_id, index_name, document_type_id, json_path, value_data_type, inserted_utc_ts)
    VALUES
      (p_index_id, p_index_name, p_document_type_id, private.tidy_json_path(p_json_path), p_value_data_type, v_utc_ts);

    -- Add audit entry.
    CALL private.log_action('ADD_INDEX', NULL, p_document_type_id, NULL, p_index_id);
  END;
END@

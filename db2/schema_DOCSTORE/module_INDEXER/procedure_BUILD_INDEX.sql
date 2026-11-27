ALTER MODULE indexer
ADD PROCEDURE build_index(p_document_type_id SMALLINT, p_index_name VARCHAR(30))
BEGIN
  DECLARE v_utc_ts TIMESTAMP(0);
  DECLARE v_index_id SMALLINT;
  DECLARE v_is_build_pending BOOLEAN;
  DECLARE v_control control_row;
  DECLARE v_history history_row;
  DECLARE v_commit_count SMALLINT DEFAULT 0;
  DECLARE v_throttle_count SMALLINT DEFAULT 0;

  -- Set UTC time
  SET v_utc_ts = CURRENT_TIMESTAMP - CURRENT_TIMEZONE;

  -- Retrieve index details
  SET (v_index_id, v_is_build_pending) =
    (
      SELECT
        index_id, is_build_pending
      FROM
        json_index
      WHERE
        document_type_id = p_document_type_id AND index_name = p_index_name
      WITH CS
    );
  IF v_index_id IS NULL THEN
    SIGNAL SQLSTATE 'DS101' SET MESSAGE_TEXT = 'Index not found';
  END IF;

  -- Shortcut exit if no build is pending
  IF NOT v_is_build_pending THEN
    RETURN;
  END IF;

  -- Initialise metadata
  SET (v_history.row_count, v_history.is_complete) = (0, FALSE);
  CALL update_metadata(v_index_id, v_utc_ts, 'BUILD', v_history, v_control);

  -- Insert document index values (if missing)
  build:
  FOR r AS c1 CURSOR WITH HOLD FOR
    SELECT
      document_id, json_document
    FROM
      json_document
    WHERE
      document_type_id = p_document_type_id AND is_valid_json
    ORDER BY
      document_id
    WITH CS WAIT FOR OUTCOME
  DO
    -- Add the index entry (if found)
    CALL private.add_index_entry(r.document_id, v_index_id, r.json_document);
    SET v_history.row_count = v_history.row_count + 1;

    -- If the commit limit is reached then update metadata and commit
    IF v_commit_count >= v_control.build_commit_limit THEN
      CALL update_metadata(v_index_id, v_utc_ts, 'BUILD', v_history, v_control);
      COMMIT;
      SET v_commit_count = 0;
      SET v_throttle_count = MOD(v_throttle_count + 1, 32768);
    END IF;
  
    -- If stop processing has been requested then exit loop
    IF v_control.is_stop_requested THEN
      LEAVE build;
    END IF;
  
    -- If the transaction throttle count is reached then sleep 1 second
    IF v_throttle_count >= v_control.build_throttle_rate THEN
      CALL dbms_lock.sleep(1);
      SET v_throttle_count = 0;
    END IF;
  END FOR;

  -- Finalise metadata
  IF v_control.is_stop_requested THEN
    SET v_history.is_complete = FALSE;
  ELSE
    SET v_history.is_complete = TRUE;
    UPDATE json_index SET is_build_pending = FALSE WHERE index_id = v_index_id;
  END IF;
  CALL update_metadata(v_index_id, v_utc_ts, 'BUILD', v_history, v_control);
  COMMIT;
END@

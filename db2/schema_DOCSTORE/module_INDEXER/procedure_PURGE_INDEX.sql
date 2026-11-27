ALTER MODULE indexer
ADD PROCEDURE purge_index(p_document_type_id SMALLINT, p_index_name VARCHAR(30))
BEGIN
  DECLARE v_utc_ts TIMESTAMP(0);
  DECLARE v_index_id SMALLINT;
  DECLARE v_value_data_type VARCHAR(20);
  DECLARE v_is_delete_pending BOOLEAN;
  DECLARE v_control control_row;
  DECLARE v_history history_row;
  DECLARE v_commit_count SMALLINT DEFAULT 0;
  DECLARE v_throttle_count SMALLINT DEFAULT 0;

  -- Set UTC time
  SET v_utc_ts = CURRENT_TIMESTAMP - CURRENT_TIMEZONE;

  -- Retrieve index details
  SET (v_index_id, v_value_data_type, v_is_delete_pending) =
    (
      SELECT
        index_id, value_data_type, is_delete_pending
      FROM
        json_index
      WHERE
        document_type_id = p_document_type_id AND index_name = p_index_name
      WITH CS
    );
  IF v_index_id IS NULL THEN
    SIGNAL SQLSTATE 'DS101' SET MESSAGE_TEXT = 'Index not found';
  END IF;
  IF NOT v_is_delete_pending THEN
    SIGNAL SQLSTATE 'DS303' SET MESSAGE_TEXT = 'Index not removed';
  END IF;

  -- Initialise metadata
  SET (v_history.row_count, v_history.is_complete) = (0, FALSE);
  CALL update_metadata(v_index_id, v_utc_ts, 'PURGE', v_history, v_control);

  -- Delete document index values
  PURGE:
  FOR r AS c1 CURSOR WITH HOLD FOR
    SELECT
      t.document_id,
      CASE WHEN COALESCE(b.index_id, d.index_id, s.index_id) IS NULL THEN FALSE ELSE TRUE END AS is_indexed
    FROM
      document_index AS t
        LEFT OUTER JOIN
      json_bigint_index_value AS b
        ON
          b.document_id = t.document_id AND
          b.index_id = v_index_id AND
          v_value_data_type = 'BIGINT'
        LEFT OUTER JOIN
      json_double_index_value AS d
        ON
          d.document_id = t.document_id AND
          d.index_id = v_index_id AND
          v_value_data_type = 'DOUBLE'
        LEFT OUTER JOIN
      json_string_index_value AS s
        ON
          s.document_id = t.document_id AND
          s.index_id = v_index_id AND
          v_value_data_type = 'VARCHAR'          
    WHERE
      t.document_type_id = p_document_type_id AND
      (
        b.index_id IS NOT NULL OR
        d.index_id IS NOT NULL OR
        s.index_id IS NOT NULL
      )
    ORDER BY
      t.document_id
    WITH CS WAIT FOR OUTCOME
  DO
    -- Remove the index entry
    CASE v_value_data_type
      WHEN 'BIGINT' THEN DELETE FROM json_bigint_index_value WHERE index_id = v_index_id AND document_id = r.document_id;
      WHEN 'DOUBLE' THEN DELETE FROM json_double_index_value WHERE index_id = v_index_id AND document_id = r.document_id;
      WHEN 'VARCHAR' THEN DELETE FROM json_string_index_value WHERE index_id = v_index_id AND document_id = r.document_id;
    END CASE;
    SET v_history.row_count = v_history.row_count + 1;

    -- If the commit limit is reached then update metadata and commit
    IF v_commit_count >= v_control.purge_commit_limit THEN
      CALL update_metadata(v_index_id, v_utc_ts, 'PURGE', v_history, v_control);
      COMMIT;
      SET v_commit_count = 0;
      SET v_throttle_count = MOD(v_throttle_count + 1, 32768);
    END IF;
  
    -- If stop processing has been requested then exit loop
    IF v_control.is_stop_requested THEN
      LEAVE purge;
    END IF;
  
    -- If the transaction throttle count is reached then sleep 1 second
    IF v_throttle_count >= v_control.purge_throttle_rate THEN
      CALL dbms_lock.sleep(1);
      SET v_throttle_count = 0;
    END IF;
  END FOR;

  -- Finalise metadata
  IF v_control.is_stop_requested THEN
    SET v_history.is_complete = FALSE;
  ELSE
    SET v_history.is_complete = TRUE;
    DELETE FROM json_index WHERE index_id = v_index_id;
  END IF;
  CALL update_metadata(v_index_id, v_utc_ts, 'PURGE', v_history, v_control);
  COMMIT;
END@

ALTER MODULE indexer
ADD PROCEDURE update_metadata
(
  p_index_id SMALLINT,
  p_start_utc_ts TIMESTAMP(0),
  p_operation_type VARCHAR(20),
  p_history history_row,
  OUT p_control control_row
)
BEGIN
  DECLARE v_utc_ts TIMESTAMP(0);

  -- Set UTC time
  SET v_utc_ts = CURRENT_TIMESTAMP - CURRENT_TIMEZONE;

  -- Retrieve control settings
  SET
    (
      p_control.build_commit_limit,
      p_control.build_throttle_rate,
      p_control.purge_commit_limit,
      p_control.purge_throttle_rate,
      p_control.is_stop_requested
    ) =
    (
      SELECT
        build_commit_limit,
        build_throttle_rate,
        purge_commit_limit,
        purge_throttle_rate,
        CASE WHEN stop_utc_ts > v_utc_ts THEN TRUE ELSE FALSE END
      FROM
        json_index_control
    );
  IF p_control.is_stop_requested IS NULL THEN
    SIGNAL SQLSTATE 'DS802' SET MESSAGE_TEXT = 'Missing JSON_INDEX_CONTROL row';
  END IF;

  -- Update history
  MERGE INTO json_index_history AS t
  USING
    (
      SELECT
        index_id, start_utc_ts, operation_type
      FROM
        json_index_history
      WHERE
        index_id = p_index_id AND start_utc_ts = p_start_utc_ts
    ) AS s
  ON
    s.index_id = t.index_id AND s.start_utc_ts = t.start_utc_ts
  WHEN NOT MATCHED THEN
    INSERT (index_id, start_utc_ts, operation_type)
    VALUES
      (p_index_id, p_start_utc_ts, p_operation_type)
  WHEN MATCHED AND t.operation_type = p_operation_type THEN
    UPDATE
    SET
      commit_count = commit_count + 1,
      row_count = row_count + p_history.row_count,
      last_commit_utc_ts = v_utc_ts,
      is_complete = p_history.is_complete
  WHEN MATCHED AND t.operation_type != p_operation_type THEN
    SIGNAL SQLSTATE 'DS302' SET MESSAGE_TEXT = 'Concurrent BUILD and PURGE operation'
  WITH CS;
END@

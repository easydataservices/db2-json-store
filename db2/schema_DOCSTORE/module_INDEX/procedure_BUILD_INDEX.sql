ALTER MODULE index
ADD PROCEDURE build_index(p_index_id SMALLINT)
BEGIN
  DECLARE v_document_type_id SMALLINT;
  DECLARE v_inserted_utc_ts TIMESTAMP(0);
  DECLARE v_json_path VARCHAR(1000);
  DECLARE v_value VARCHAR(60);

  -- Retrieve index details
  SET (v_document_type_id, v_inserted_utc_ts, v_json_path) =
    (
      SELECT document_type_id, inserted_utc_ts, json_path FROM json_index WHERE index_id = p_index_id AND is_build_pending
      WITH CS
    );

  -- Do not allow index build if build delay has not yet expired
  IF v_inserted_utc_ts + g_build_delay_seconds SECONDS >= CURRENT_TIMESTAMP - CURRENT_TIMEZONE THEN
    SIGNAL SQLSTATE 'DS701' SET MESSAGE_TEXT = 'Index build delay period has not expired';
  END IF;

  -- Insert document index value (if missing)
  FOR r AS c1 CURSOR WITH HOLD FOR
    SELECT document_id FROM document_index WHERE document_type_id = v_document_type_id ORDER BY document_id WITH CS
  DO
    CALL build_document_index(r.document_id, p_index_id)
  END FOR;
END@

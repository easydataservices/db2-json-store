ALTER MODULE docuser
ADD FUNCTION get_json_string_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value VARCHAR(1000)
  )
BEGIN
  DECLARE v_is_authorised BOOLEAN;
  DECLARE v_index_id SMALLINT;

  -- Check authorisation
  SET v_is_authorised = is_viewer(p_document_type_id);

  -- Validate JSON path
  IF NOT private.is_json_path(p_json_path) THEN
    SIGNAL SQLSTATE 'DS202' SET MESSAGE_TEXT = 'Invalid JSON path';
  END IF;

  -- Look for an index matching the criteria
  SET v_index_id = usable_index_id(p_document_type_id, p_json_path, NULL);

  -- If no index exists then pipe results from documents; otherwise from the index
  IF v_index_id IS NULL THEN
    FOR r AS
      SELECT document_id, value FROM TABLE(get_unindexed_string_values(p_document_type_id, p_json_path))
    DO
      PIPE(r.document_id, r.value);
    END FOR;
  ELSE
    FOR r AS
      SELECT document_id, value FROM TABLE(get_indexed_string_values(v_index_id))
    DO
      PIPE(r.document_id, r.value);
    END FOR;
  END IF;

  -- Return
  RETURN;
END@

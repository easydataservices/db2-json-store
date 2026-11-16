ALTER MODULE docuser
ADD PROCEDURE remove_json_document(p_document_id BIGINT)
BEGIN
  DECLARE v_document_type_id SMALLINT;
  DECLARE v_check BOOLEAN;

  -- Lock document, and check user is authorised to remove it
  SET v_document_type_id =
    (
      SELECT document_type_id FROM document_index WHERE document_id = p_document_id
      WITH RS USE AND KEEP UPDATE LOCKS
    );
  SET v_check = is_remover(v_document_type_id);

  -- Shortcut exit if document is already removed
  IF v_document_type_id IS NULL THEN
    RETURN;
  END IF;

  -- Perform updates
  BEGIN ATOMIC
    -- Logically delete the document
    UPDATE document_index
    SET
      deleted_utc_ts = CURRENT_TIMESTAMP - CURRENT_TIMEZONE
    WHERE
      document_id = p_document_id;
    
    -- Add audit entry.
    CALL private.log_action('REMOVE_DOCUMENT', p_document_id, v_document_type_id, NULL, NULL);
  END;
END@

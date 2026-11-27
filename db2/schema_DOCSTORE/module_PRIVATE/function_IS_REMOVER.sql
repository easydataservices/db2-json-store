ALTER MODULE private
ADD FUNCTION is_remover(p_document_type_id SMALLINT) RETURNS BOOLEAN
  DETERMINISTIC
  NO EXTERNAL ACTION
BEGIN
  DECLARE v_remove_document_role VARCHAR(30);

  -- Look up document type
  SET v_remove_document_role =
    (SELECT remove_document_role FROM document_type WHERE document_type_id = p_document_type_id WITH CS);

  -- Signal an exception when the user is not authorised
  IF VERIFY_ROLE_FOR_USER(SESSION_USER, v_remove_document_role) = 0 THEN
    SIGNAL SQLSTATE 'DS401' SET MESSAGE_TEXT = 'Not authorised';
  END IF;

  -- Return
  RETURN TRUE;
END@

ALTER MODULE private
ADD FUNCTION is_new_external_ref(p_document_type_id SMALLINT, p_external_ref VARCHAR(30)) RETURNS BOOLEAN
BEGIN
  DECLARE v_is_duplicate_external_ref_blocked BOOLEAN;
  DECLARE v_is_new_external_ref BOOLEAN;

  -- Look up flag that controls whether or not duplicate external references are allowed
  SET v_is_duplicate_external_ref_blocked =
    (SELECT is_duplicate_external_ref_blocked FROM document_type WHERE document_type_id = p_document_type_id WITH CS);

  -- Look up and lock external reference  
  SET v_is_new_external_ref =
    (
      SELECT FALSE FROM external_reference WHERE external_ref = p_external_ref AND external_ref_type_id = p_document_type_id
      WITH RR USE AND KEEP UPDATE LOCKS
    );
  SET v_is_new_external_ref = COALESCE(v_is_new_external_ref, TRUE);

  -- Reject disallowed duplicate external reference
  IF v_is_duplicate_external_ref_blocked AND NOT v_is_new_external_ref THEN
    SIGNAL SQLSTATE 'DS301' SET MESSAGE_TEXT = 'Disallowed duplicate EXTERNAL_REF';
  END IF;

  -- Return
  RETURN v_is_new_external_ref;
END@

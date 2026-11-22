ALTER MODULE admin
ADD PROCEDURE set_duplicate_external_ref_blocked(p_document_type_id SMALLINT, p_is_blocked BOOLEAN)
BEGIN
  DECLARE v_is_blocked BOOLEAN;

  -- Look up current setting; shortcut exit if there is no change
  SET v_is_blocked =
    (SELECT is_duplicate_external_ref_blocked FROM document_type WHERE document_type_id = p_document_type_id WITH RS);
  IF v_is_blocked IS NOT DISTINCT FROM p_is_blocked THEN
    RETURN;
  END IF;

  -- Perform updates
  BEGIN ATOMIC
    UPDATE document_type
    SET
      is_duplicate_external_ref_blocked = p_is_blocked
    WHERE
      document_type_id = p_document_type_id;
  
    -- Add audit entry.
    IF p_is_blocked THEN
      CALL private.log_action('BLOCK_DUPLICATE_REF', NULL, p_document_type_id, NULL, NULL);
    ELSE
      CALL private.log_action('ALLOW_DUPLICATE_REF', NULL, p_document_type_id, NULL, NULL);
    END IF;
  END;
END@

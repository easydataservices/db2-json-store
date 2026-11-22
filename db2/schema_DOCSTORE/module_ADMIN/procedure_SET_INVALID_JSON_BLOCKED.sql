ALTER MODULE admin
ADD PROCEDURE set_invalid_json_blocked(p_is_blocked BOOLEAN)
BEGIN
  DECLARE v_is_blocked BOOLEAN;

  -- Look up current setting; shortcut exit if there is no change
  SET v_is_blocked = (SELECT is_invalid_json_blocked FROM store_control WITH RS);
  IF v_is_blocked IS NOT DISTINCT FROM p_is_blocked THEN
    RETURN;
  END IF;

  -- Perform updates
  BEGIN ATOMIC
    UPDATE store_control SET is_invalid_json_blocked = p_is_blocked;
  
    -- Add audit entry.
    IF p_is_blocked THEN
      CALL private.log_action('BLOCK_INVALID_JSON', NULL, NULL, NULL, NULL);
    ELSE
      CALL private.log_action('ALLOW_INVALID_JSON', NULL, NULL, NULL, NULL);
    END IF;
  END;
END@

ALTER MODULE private
ADD FUNCTION is_invalid_json_blocked() RETURNS BOOLEAN
BEGIN
  DECLARE v_result BOOLEAN;
  
  SET v_result = (SELECT is_invalid_json_blocked FROM store_control WITH CS);
  IF v_result IS NULL THEN
    SIGNAL SQLSTATE 'DS801' SET MESSAGE_TEXT = 'Missing STORE_CONTROL row';
  END IF;

  -- Return
  RETURN v_result;
END@

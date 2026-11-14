CREATE OR REPLACE FUNCTION is_json_document(p_json CLOB(2M)) RETURNS BOOLEAN
BEGIN
  -- Handler for invalid JSON
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    RETURN FALSE;

  -- Check input text is a JSON document
  IF LTRIM(p_json) NOT LIKE '{%' OR JSON_TO_BSON(p_json) IS NULL THEN
    SIGNAL SQLSTATE 'DS201' SET MESSAGE_TEXT = 'Invalid JSON document';
  END IF;

  -- Return
  RETURN TRUE;
END@

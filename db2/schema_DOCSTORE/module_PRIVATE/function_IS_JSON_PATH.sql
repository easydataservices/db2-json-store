ALTER MODULE private
ADD FUNCTION is_json_path(p_json_path VARCHAR(1000)) RETURNS BOOLEAN
BEGIN
  DECLARE v_dummy CHAR(1);

  -- Handler for invalid JSON
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    RETURN FALSE;

  -- Hander for member
  -- Check input text is a JSON path expression
  IF p_json_path IS NULL OR (p_json_path NOT LIKE 'strict $%' AND p_json_path NOT LIKE 'lax $%') THEN
    RETURN FALSE;
  END IF;
  IF p_json_path LIKE 'strict $%' THEN
    SET p_json_path = 'lax $' || SUBSTR(p_json_path, 9);
  END IF;
  SET v_dummy = JSON_VALUE('{}', p_json_path RETURNING CHAR(1) ERROR ON ERROR);

  -- Return
  RETURN TRUE;
END@

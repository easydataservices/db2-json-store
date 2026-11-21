ALTER MODULE private
ADD FUNCTION is_json_path(p_json_path VARCHAR(1000)) RETURNS BOOLEAN
BEGIN
  DECLARE v_dummy CHAR(1);

  -- Handler for invalid JSON
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    RETURN FALSE;

  -- Check input text is a JSON path expression
  IF p_json_path IS NULL OR NOT REGEXP_LIKE(tidy_json_path(p_json_path), '^((\$|strict \$))') THEN
    RETURN FALSE;
  END IF;
  IF p_json_path LIKE 'strict $%' THEN
    SET p_json_path = '$' || SUBSTR(p_json_path, 9);
  END IF;
  SET v_dummy = JSON_VALUE('{}', p_json_path RETURNING CHAR(1) ERROR ON ERROR);

  -- Return
  RETURN TRUE;
END@

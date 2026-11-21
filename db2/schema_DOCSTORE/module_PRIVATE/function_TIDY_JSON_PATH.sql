ALTER MODULE private
ADD FUNCTION tidy_json_path(p_json_path VARCHAR(1000)) RETURNS VARCHAR(1000)
BEGIN
  IF REGEXP_LIKE(p_json_path, '^((strict\s+))') THEN
    RETURN 'strict ' || REGEXP_REPLACE(p_json_path, '^((strict\s+))');
  ELSE
    RETURN REGEXP_REPLACE(p_json_path, '^(((lax)?\s+))');
  END IF;
END@

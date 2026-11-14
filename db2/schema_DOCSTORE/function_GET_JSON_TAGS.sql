CREATE OR REPLACE FUNCTION get_json_tags(p_tags_json_array VARCHAR(2000)) RETURNS TABLE (tag VARCHAR(20))
BEGIN
  DECLARE v_tags_json_array VARCHAR(2048);
  DECLARE v_index SMALLINT DEFAULT 0;
  DECLARE v_path VARCHAR(20) DEFAULT 'strict $.tags[0]';

  -- Handler for invalid JSON
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SIGNAL SQLSTATE 'DS202' SET MESSAGE_TEXT = 'Invalid tags JSON array';

  -- Shortcut exit for null input
  IF p_tags_json_array IS NULL THEN
    RETURN;
  END IF;

  -- Make the array a document (Db2 path query needs a document)
  SET v_tags_json_array = '{"tags" : ' || p_tags_json_array || '}';
  WHILE JSON_EXISTS(v_tags_json_array, v_path ERROR ON ERROR) DO
    PIPE (JSON_VALUE(v_tags_json_array, v_path RETURNING VARCHAR(20) ERROR ON ERROR));
    SET v_index = v_index + 1;
    SET v_path = 'strict $.tags[' || v_index || ']';
  END WHILE;

  -- Return
  RETURN;
END@

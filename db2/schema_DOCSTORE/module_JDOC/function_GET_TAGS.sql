ALTER MODULE jdoc
ADD FUNCTION get_tags(p_tags_json_array VARCHAR(2000)) RETURNS TABLE (tag VARCHAR(30), value VARCHAR(60))
BEGIN
  DECLARE v_tags_json_array VARCHAR(2048);
  DECLARE v_index SMALLINT DEFAULT 0;
  DECLARE v_path VARCHAR(20) DEFAULT '$.tags[0]';
  DECLARE v_element VARCHAR(2048);
  DECLARE v_tag VARCHAR(30);
  DECLARE v_value VARCHAR(60);

  -- Handler for invalid JSON
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SIGNAL SQLSTATE 'DS203' SET MESSAGE_TEXT = 'Invalid tags JSON array';

  -- Shortcut exit for null input
  IF p_tags_json_array IS NULL THEN
    RETURN;
  END IF;

  -- Make the array a document (Db2 path query needs a document)
  SET v_tags_json_array = '{"tags" : ' || p_tags_json_array || '}';

  -- Iterate through the tags, also retrieving values where provided, and pipe results
  WHILE JSON_EXISTS(v_tags_json_array, v_path ERROR ON ERROR) DO
    SET v_element =
      (
        SELECT
          tag
        FROM
          JSON_TABLE(v_tags_json_array FORMAT JSON, 'strict $' COLUMNS (tag VARCHAR(2000) FORMAT JSON PATH v_path) ERROR ON ERROR)
      );
    SET v_element = '{"tag" : ' || v_element || '}';
    SET v_tag = JSON_QUERY(v_element, '$.tag[0]' RETURNING VARCHAR(30) OMIT QUOTES ERROR ON ERROR);
    SET v_value = JSON_QUERY(v_element, '$.tag[1]' RETURNING VARCHAR(60) OMIT QUOTES ERROR ON ERROR);
    IF JSON_EXISTS(v_element, '$.tag[2]' ERROR ON ERROR) THEN
      SIGNAL SQLSTATE 'DS203';
    END IF;
    PIPE (v_tag, v_value);
    SET v_index = v_index + 1;
    SET v_path = '$.tags[' || v_index || ']';
  END WHILE;

  -- Return
  RETURN;
END@

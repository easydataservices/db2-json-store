ALTER MODULE admin
ADD PROCEDURE remove_index
(
  p_document_type_id SMALLINT, p_index_name VARCHAR(30)
)
BEGIN
  DECLARE v_index_id SMALLINT;

  -- Retrieve index details
  SET v_index_id =
    (
      SELECT
        index_id
      FROM
        json_index
      WHERE
        document_type_id = p_document_type_id AND index_name = p_index_name AND NOT is_delete_pending
      WITH CS
    );
  IF v_index_id IS NULL THEN
    SIGNAL SQLSTATE 'DS101' SET MESSAGE_TEXT = 'Index not found';
  END IF;

  -- Perform updates
  BEGIN ATOMIC
    UPDATE json_index SET is_delete_pending = TRUE WHERE index_id = v_index_id;

    -- Add audit entry
    CALL private.log_action('REMOVE_INDEX', NULL, p_document_type_id, NULL, v_index_id);
  END;
END@

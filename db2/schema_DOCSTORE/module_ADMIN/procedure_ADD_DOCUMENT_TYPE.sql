ALTER MODULE admin
ADD PROCEDURE add_document_type
(
  p_document_type_id SMALLINT,
  p_document_type_name VARCHAR(30),
  p_view_document_role VARCHAR(30),
  p_add_document_role VARCHAR(30),
  p_remove_document_role VARCHAR(30),
  p_define_tags_role VARCHAR(30)
)
BEGIN ATOMIC
  -- Insert new dcocument type
  INSERT INTO document_type
  (
    document_type_id, document_type_name, view_document_role, add_document_role, remove_document_role, define_tags_role
  )
  VALUES
    (
      p_document_type_id,
      p_document_type_name,
      p_view_document_role,
      p_add_document_role,
      p_remove_document_role,
      p_define_tags_role
    );

  -- Add audit entry
  CALL private.log_action('ADD_DOCUMENT_TYPE', NULL, p_document_type_id, NULL, NULL);
END@

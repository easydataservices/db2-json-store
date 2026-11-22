ALTER MODULE info
ADD FUNCTION document_type_id(p_document_type_name VARCHAR(30)) RETURNS SMALLINT
RETURN
  (
    SELECT document_type_id FROM document_type WHERE document_type_name = p_document_type_name WITH CS
  )@

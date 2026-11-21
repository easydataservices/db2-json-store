ALTER MODULE info
ADD FUNCTION document_type_name(p_document_type_id SMALLINT) RETURNS VARCHAR(30)
RETURN
  (
    SELECT document_type_name FROM document_type WHERE document_type_id = p_document_type_id WITH CS
  )@

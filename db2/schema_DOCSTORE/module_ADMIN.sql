CREATE OR REPLACE MODULE admin;

-- Allow or block invalid JSON
ALTER MODULE admin
PUBLISH PROCEDURE set_invalid_json_blocked(p_is_blocked BOOLEAN);

-- Allow or block duplicate external references for specified document type
ALTER MODULE admin
PUBLISH PROCEDURE set_duplicate_external_ref_blocked(p_document_type_id SMALLINT, p_is_blocked BOOLEAN);

-- Add a document type
ALTER MODULE admin
PUBLISH PROCEDURE add_document_type
(
  p_document_type_id SMALLINT,
  p_document_type_name VARCHAR(30),
  p_view_document_role VARCHAR(30),
  p_add_document_role VARCHAR(30),
  p_remove_document_role VARCHAR(30)
);

-- Add an index
ALTER MODULE admin
PUBLISH PROCEDURE add_json_index
(
  p_document_type_id SMALLINT,
  p_index_name VARCHAR(30),
  p_json_path VARCHAR(1000),
  p_value_data_type VARCHAR(20),
  OUT p_index_id SMALLINT
);

-- Remove an index
ALTER MODULE admin
PUBLISH PROCEDURE remove_json_index
(
  p_document_type_id SMALLINT,
  p_index_name VARCHAR(30)
);

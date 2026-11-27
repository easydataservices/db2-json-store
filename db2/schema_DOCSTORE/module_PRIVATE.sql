CREATE OR REPLACE MODULE private;

-- Calculate partition number for new document
ALTER MODULE private
PUBLISH FUNCTION get_partition_num(p_document_id BIGINT) RETURNS SMALLINT;

-- Return flag indicating whether invalid JSON documents should be rejected
ALTER MODULE private
PUBLISH FUNCTION is_invalid_json_blocked() RETURNS BOOLEAN;

-- Return flag indicating whether external reference is new (or already exists)
ALTER MODULE private
PUBLISH FUNCTION is_new_external_ref(p_document_type_id SMALLINT, p_external_ref VARCHAR(30)) RETURNS BOOLEAN;

-- Return flag indicate whether supplied text is a JSON document
ALTER MODULE private
PUBLISH FUNCTION is_json_document(p_json CLOB(2M)) RETURNS BOOLEAN;

-- Standardise a JSON path expression
ALTER MODULE private
PUBLISH FUNCTION tidy_json_path(p_json_path VARCHAR(1000)) RETURNS VARCHAR(1000);

-- Return flag indicate whether supplied JSON path is a valid path expression
ALTER MODULE private
PUBLISH FUNCTION is_json_path(p_json_path VARCHAR(1000)) RETURNS BOOLEAN;

-- Log an auditable action
ALTER MODULE private
PUBLISH PROCEDURE log_action
(
  p_action VARCHAR(30), p_document_id BIGINT, p_document_type_id SMALLINT, p_tag_id SMALLINT, p_index_id SMALLINT
);

-- Add index entry for specified document and index
ALTER MODULE private
PUBLISH PROCEDURE add_index_entry(p_document_id BIGINT, p_index_id SMALLINT, p_json_document CLOB(2M));

-- Remove index entry for specified document and index
ALTER MODULE private
PUBLISH PROCEDURE remove_index_entry(p_document_id BIGINT, p_index_id SMALLINT);

-- Validate whether user can add documents of the specified document type
ALTER MODULE private
PUBLISH FUNCTION is_adder(p_document_type_id SMALLINT) RETURNS BOOLEAN;

-- Validate whether user can remove documents of the specified document type
ALTER MODULE private
PUBLISH FUNCTION is_remover(p_document_type_id SMALLINT) RETURNS BOOLEAN;

-- Validate whether user can view documents of the specified document type
ALTER MODULE private
PUBLISH FUNCTION is_viewer(p_document_type_id SMALLINT) RETURNS BOOLEAN;

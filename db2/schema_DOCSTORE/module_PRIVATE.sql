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

-- Log an auditable action
ALTER MODULE private
PUBLISH PROCEDURE log_action
(
  p_action VARCHAR(20), p_document_id BIGINT, p_document_type_id SMALLINT, p_tag_id SMALLINT, p_index_id SMALLINT
);

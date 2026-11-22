CREATE OR REPLACE MODULE info;

-- List indexes for specified document type
ALTER MODULE info
PUBLISH FUNCTION get_indexes(p_document_type_id SMALLINT)
  RETURNS TABLE
  (
    index_id SMALLINT,
    index_name VARCHAR(30),
    json_path VARCHAR(1000),
    value_data_type VARCHAR(20),
    inserted_utc_ts TIMESTAMP(0),
    is_build_pending BOOLEAN,
    is_delete_pending BOOLEAN
  );

-- Return document type identifier for specified document type name
ALTER MODULE info
PUBLISH FUNCTION document_type_id(p_document_type_name VARCHAR(30)) RETURNS SMALLINT;

-- Return document type name for specified document type identifier
ALTER MODULE info
PUBLISH FUNCTION document_type_name(p_document_type_id SMALLINT) RETURNS VARCHAR(30);

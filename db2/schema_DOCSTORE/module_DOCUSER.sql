CREATE OR REPLACE MODULE docuser;

-- Add a document
ALTER MODULE docuser
PUBLISH PROCEDURE add_json_document
(
  INOUT p_document_id BIGINT,
  p_document_type_id SMALLINT,
  p_external_ref VARCHAR(30),
  p_tags_json_array VARCHAR(2000),
  p_json_document CLOB(2M)
);

-- Remove a document
ALTER MODULE docuser
PUBLISH PROCEDURE remove_json_document(p_document_id BIGINT);

-- Retrieve a document
ALTER MODULE docuser
PUBLISH FUNCTION get_json_document(p_document_id BIGINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    inserted_utc_ts TIMESTAMP(0),
    document_type_name VARCHAR(30),
    external_ref VARCHAR(30),
    is_valid_json BOOLEAN,
    json_document CLOB(2M)
  );

-- Retrieve all documents for the specified type
ALTER MODULE docuser
PUBLISH FUNCTION get_all_json_documents(p_document_type_id SMALLINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    inserted_utc_ts TIMESTAMP(0),
    document_type_name VARCHAR(30),
    external_ref VARCHAR(30),
    is_valid_json BOOLEAN,
    json_document CLOB(2M)
  );

-- Retrieve JSON BIGINT values for the specified document type and JSON path
ALTER MODULE docuser
PUBLISH FUNCTION get_json_bigint_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

-- Retrieve JSON DOUBLE values for the specified document type and JSON path
ALTER MODULE docuser
PUBLISH FUNCTION get_json_double_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value DOUBLE
  );

-- Retrieve JSON VARCHAR values for the specified document type and JSON path
ALTER MODULE docuser
PUBLISH FUNCTION get_json_string_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value VARCHAR(1000)
  );

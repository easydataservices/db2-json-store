CREATE OR REPLACE MODULE jdoc;

-- Add a document
ALTER MODULE jdoc
PUBLISH PROCEDURE add_document
(
  INOUT p_document_id BIGINT,
  p_document_type_id SMALLINT,
  p_external_ref VARCHAR(30),
  p_tags_json_array VARCHAR(2000),
  p_json_document CLOB(2M)
);

-- Remove a document
ALTER MODULE jdoc
PUBLISH PROCEDURE remove_document(p_document_id BIGINT);

-- Retrieve a document
ALTER MODULE jdoc
PUBLISH FUNCTION get_document(p_document_id BIGINT)
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
ALTER MODULE jdoc
PUBLISH FUNCTION get_all_documents(p_document_type_id SMALLINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    inserted_utc_ts TIMESTAMP(0),
    document_type_name VARCHAR(30),
    external_ref VARCHAR(30),
    is_valid_json BOOLEAN,
    json_document CLOB(2M)
  );

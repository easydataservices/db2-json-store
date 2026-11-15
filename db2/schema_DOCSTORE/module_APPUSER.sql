CREATE OR REPLACE MODULE appuser;

ALTER MODULE appuser
PUBLISH PROCEDURE add_json_document
(
  INOUT p_document_id BIGINT,
  p_document_type_id SMALLINT,
  p_external_ref VARCHAR(30),
  p_tags_json_array VARCHAR(2000),
  p_json_document CLOB(2M)
);

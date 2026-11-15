CREATE OR REPLACE MODULE auxiliary;

ALTER MODULE auxiliary
PUBLISH PROCEDURE build_document_index(p_document_id BIGINT, p_index_id SMALLINT);

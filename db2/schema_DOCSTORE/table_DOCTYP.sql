-- DOCUMENT_TYPE table
CREATE TABLE doctyp
(
  document_type_id SMALLINT NOT NULL,
  document_type_name VARCHAR(30) NOT NULL,
  is_duplicate_external_ref_blocked BOOLEAN NOT NULL DEFAULT TRUE,
  view_document_role VARCHAR(30) NOT NULL,
  add_document_role VARCHAR(30) NOT NULL,
  delete_document_role VARCHAR(30)
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS document_type FOR TABLE doctyp;

ALTER TABLE doctyp
ADD CONSTRAINT doctyp_pk PRIMARY KEY (document_type_id);

ALTER TABLE doctyp
ADD CONSTRAINT doctyp_uk1 UNIQUE (document_type_name);

ALTER TABLE doctyp
ADD CONSTRAINT doctyp_c1 CHECK (document_type_name != '');

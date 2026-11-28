-- Table EXTERNAL_REFERENCE

CREATE TABLE extref
(
  external_ref VARCHAR(30) NOT NULL,
  document_type_id SMALLINT NOT NULL
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS external_reference FOR TABLE extref;

ALTER TABLE extref
ADD CONSTRAINT extref_pk PRIMARY KEY (external_ref, document_type_id);

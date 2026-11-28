-- Table EXTERNAL_REFERENCE_TAG

CREATE TABLE exreta
(
  external_ref VARCHAR(30) NOT NULL,
  document_type_id SMALLINT NOT NULL,
  tag_id SMALLINT NOT NULL,
  inserted_utc_ts TIMESTAMP(0) NOT NULL,
  value VARCHAR(60),
  deleted_utc_ts TIMESTAMP(0)
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS external_reference_tag FOR TABLE exreta;

ALTER TABLE exreta
ADD CONSTRAINT exreta_pk PRIMARY KEY (external_ref, document_type_id, tag_id, inserted_utc_ts);

ALTER TABLE exreta
ADD CONSTRAINT exreta_extref_fk1 FOREIGN KEY (external_ref, document_type_id) REFERENCES extref;

ALTER TABLE exreta
ADD CONSTRAINT exreta_tagzzz_fk1 FOREIGN KEY (document_type_id, tag_id) REFERENCES tagzzz;

CREATE UNIQUE INDEX exreta_ix1 ON exreta(document_type_id, tag_id);

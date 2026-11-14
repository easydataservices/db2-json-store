-- DOCUMENT_TAG table
CREATE TABLE doctag
(
  document_id BIGINT NOT NULL,
  document_type_id SMALLINT NOT NULL,
  tag VARCHAR(20) NOT NULL,
  inserted_utc_ts TIMESTAMP(0) NOT NULL,
  deleted_utc_ts TIMESTAMP(0)
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS document_tag FOR TABLE doctag;

ALTER TABLE doctag
ADD CONSTRAINT doctag_pk PRIMARY KEY (document_id, tag);

ALTER TABLE doctag
ADD CONSTRAINT doctag_dotyta_fk1 FOREIGN KEY (document_type_id, tag) REFERENCES dotyta;

CREATE UNIQUE INDEX doctag_ix1 ON doctag(document_type_id, tag, document_id);

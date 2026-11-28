-- Table DOCUMENT_TAG

CREATE TABLE doctag
(
  document_id BIGINT NOT NULL,
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

CREATE ALIAS document_tag FOR TABLE doctag;

ALTER TABLE doctag
ADD CONSTRAINT doctag_pk PRIMARY KEY (document_id, document_type_id, tag_id, inserted_utc_ts);

ALTER TABLE doctag
ADD CONSTRAINT doctag_docind_fk1 FOREIGN KEY (document_id) REFERENCES docind;

ALTER TABLE doctag
ADD CONSTRAINT doctag_tagzzz_fk1 FOREIGN KEY (document_type_id, tag_id) REFERENCES tagzzz;

CREATE UNIQUE INDEX doctag_ix1 ON doctag(document_type_id, tag_id);

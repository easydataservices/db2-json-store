-- DOCUMENT_INDEX table
CREATE TABLE docind
(
  document_id BIGINT NOT NULL,
  partition_num SMALLINT NOT NULL,
  document_type_id SMALLINT NOT NULL,
  inserted_utc_ts TIMESTAMP(0) NOT NULL,
  deleted_utc_ts TIMESTAMP(0),
  is_valid_json BOOLEAN NOT NULL,
  external_ref VARCHAR(30),
  external_ref_type_id SMALLINT NOT NULL
    GENERATED ALWAYS AS (CASE WHEN external_ref IS NULL THEN NULL ELSE document_type_id END)
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS document_index FOR TABLE docind;

CREATE UNIQUE INDEX docind_pk ON docind(document_id) INCLUDE (partition_num, inserted_utc_ts);

ALTER TABLE docind
ADD CONSTRAINT docind_pk PRIMARY KEY (document_id);

ALTER TABLE docind
ADD CONSTRAINT docind_doctyp_fk1 FOREIGN KEY (document_type_id) REFERENCES doctyp;

ALTER TABLE docind
ADD CONSTRAINT docind_extref_fk1 FOREIGN KEY (external_ref, external_ref_type_id) REFERENCES extref;

ALTER TABLE docind
ADD CONSTRAINT docind_c1 CHECK (document_id > 0);

CREATE INDEX docind_ix1 ON docind(external_ref_type_id, external_ref) EXCLUDE NULL KEYS;

CREATE INDEX docind_ix2 ON docind(document_type_id, document_id);

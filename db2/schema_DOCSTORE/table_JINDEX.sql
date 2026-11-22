-- Table JSON_INDEX

CREATE TABLE jindex
(
  index_id SMALLINT NOT NULL,
  index_name VARCHAR(30) NOT NULL,
  document_type_id SMALLINT NOT NULL,
  json_path VARCHAR(1000) NOT NULL,
  value_data_type VARCHAR(20) NOT NULL DEFAULT 'VARCHAR',
  inserted_utc_ts TIMESTAMP(0) NOT NULL,
  is_build_pending BOOLEAN NOT NULL DEFAULT TRUE,
  is_delete_pending BOOLEAN NOT NULL DEFAULT FALSE
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS json_index FOR TABLE jindex;

ALTER TABLE jindex
ADD CONSTRAINT jindex_pk PRIMARY KEY (index_id);

ALTER TABLE jindex
ADD CONSTRAINT jindex_uk1 UNIQUE (document_type_id, index_name);

ALTER TABLE jindex
ADD CONSTRAINT jindex_uk2 UNIQUE (document_type_id, json_path);

ALTER TABLE jindex
ADD CONSTRAINT jindex_doctyp_fk1 FOREIGN KEY (document_type_id) REFERENCES doctyp;

ALTER TABLE jindex
ADD CONSTRAINT jindex_c1 CHECK (value_data_type IN ('VARCHAR', 'BIGINT', 'DOUBLE'));

ALTER TABLE jindex
ADD CONSTRAINT jindex_c2 CHECK (NOT is_build_pending OR NOT is_delete_pending);

-- json_index table
CREATE TABLE jsonix
(
  index_id SMALLINT NOT NULL,
  index_name VARCHAR(30) NOT NULL,
  document_type_id SMALLINT NOT NULL,
  json_path VARCHAR(1000) NOT NULL,
  inserted_utc_ts TIMESTAMP(0) NOT NULL,
  is_build_pending BOOLEAN NOT NULL DEFAULT FALSE,
  is_delete_pending BOOLEAN NOT NULL DEFAULT FALSE
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS json_index FOR TABLE jsonix;

ALTER TABLE jsonix
ADD CONSTRAINT jsonix_pk PRIMARY KEY (index_id);

ALTER TABLE jsonix
ADD CONSTRAINT jsonix_uk1 UNIQUE (document_type_id, index_name);

ALTER TABLE jsonix
ADD CONSTRAINT jsonix_uk2 UNIQUE (document_type_id, json_path);

ALTER TABLE jsonix
ADD CONSTRAINT jsonix_doctyp_fk1 FOREIGN KEY (document_type_id) REFERENCES doctyp;
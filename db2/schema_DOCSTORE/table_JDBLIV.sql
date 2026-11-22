-- Table JSON_DOUBLE_INDEX_VALUE

CREATE TABLE jdbliv
(
  index_id SMALLINT NOT NULL,
  document_id BIGINT NOT NULL,
  value DOUBLE NOT NULL
)
  ORGANIZE BY DIMENSIONS (index_id)
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS json_double_index_value FOR TABLE jdbliv;

ALTER TABLE jdbliv
ADD CONSTRAINT jdbliv_pk PRIMARY KEY (index_id, document_id);

ALTER TABLE jdbliv
ADD CONSTRAINT jdbliv_jindex_fk1 FOREIGN KEY (index_id) REFERENCES jindex;

CREATE INDEX jdbliv_ix1 ON jdbliv(index_id, value, document_id);

-- Table JSON_BIGINT_INDEX_VALUE

CREATE TABLE jbigiv
(
  index_id SMALLINT NOT NULL,
  document_id BIGINT NOT NULL,
  value BIGINT NOT NULL
)
  ORGANIZE BY DIMENSIONS (index_id)
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS json_bigint_index_value FOR TABLE jbigiv;

ALTER TABLE jbigiv
ADD CONSTRAINT jbigiv_pk PRIMARY KEY (index_id, document_id);

ALTER TABLE jbigiv
ADD CONSTRAINT jbigiv_jindex_fk1 FOREIGN KEY (index_id) REFERENCES jindex;

CREATE INDEX jbigiv_ix1 ON jbigiv(index_id, value, document_id);

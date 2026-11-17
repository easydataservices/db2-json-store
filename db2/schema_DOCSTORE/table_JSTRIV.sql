-- Table JSON_STRING_INDEX_VALUE

CREATE TABLE jstriv
(
  index_id SMALLINT NOT NULL,
  document_id BIGINT NOT NULL,
  value VARCHAR(1000) NOT NULL
)
  ORGANIZE BY DIMENSIONS (index_id)
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS json_string_index_value FOR TABLE jstriv;

ALTER TABLE jstriv
ADD CONSTRAINT jstriv_pk PRIMARY KEY (index_id, document_id);

ALTER TABLE jstriv
ADD CONSTRAINT jstriv_jindex_fk1 FOREIGN KEY (index_id) REFERENCES jindex;

CREATE INDEX jstriv_ix1 ON jstriv(index_id, value, document_id);

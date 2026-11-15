-- JSON_INDEX_VALUE table
CREATE TABLE jixval
(
  index_id SMALLINT NOT NULL,
  document_id BIGINT NOT NULL,
  value VARCHAR(60) NOT NULL
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS json_index_value FOR TABLE jixval;

ALTER TABLE jixval
ADD CONSTRAINT jixval_pk PRIMARY KEY (index_id, document_id);

ALTER TABLE jixval
ADD CONSTRAINT jixval_jsonix_fk1 FOREIGN KEY (index_id) REFERENCES jsonix;

CREATE INDEX jixval_ix1 ON jixval(index_id, value, document_id);

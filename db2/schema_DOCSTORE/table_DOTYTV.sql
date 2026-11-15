-- DOCUMENT_TYPE_TAG_VALUE table
CREATE TABLE dotytv
(
  document_type_id SMALLINT NOT NULL,
  tag_id SMALLINT NOT NULL,
  value VARCHAR(20) NOT NULL
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS document_type_tag_value FOR TABLE dotytv;

ALTER TABLE dotytv
ADD CONSTRAINT dotytv_pk PRIMARY KEY (document_type_id, tag_id, value);

ALTER TABLE dotytv
ADD CONSTRAINT dotytv_dotyta_fk1 FOREIGN KEY (document_type_id, tag_id) REFERENCES dotyta;

-- DOCUMENT_TYPE_TAG table
CREATE TABLE dotyta
(
  document_type_id SMALLINT NOT NULL,
  tag_id SMALLINT NOT NULL,
  tag VARCHAR(20) NOT NULL
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS document_type_tag FOR TABLE dotyta;

ALTER TABLE dotyta
ADD CONSTRAINT dotyta_pk PRIMARY KEY (document_type_id, tag_id);

ALTER TABLE dotyta
ADD CONSTRAINT dotyta_uk1 UNIQUE (document_type_id, tag);

ALTER TABLE dotyta
ADD CONSTRAINT dotyta_c1 CHECK (tag_id > 0);

ALTER TABLE dotyta
ADD CONSTRAINT dotyta_c2 CHECK (tag != '');

-- Table TAG_DOMAIN_VALUE

CREATE TABLE tadova
(
  document_type_id SMALLINT NOT NULL,
  tag_id SMALLINT NOT NULL,
  domain_value VARCHAR(60) NOT NULL
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS tag_domain_value FOR TABLE tadova;

ALTER TABLE tadova
ADD CONSTRAINT tadova_pk PRIMARY KEY (document_type_id, tag_id, domain_value);

ALTER TABLE tadova
ADD CONSTRAINT tadova_tagzzz_fk1 FOREIGN KEY (document_type_id, tag_id) REFERENCES tagzzz;

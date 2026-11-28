-- Table TAG

CREATE TABLE tagzzz
(
  document_type_id SMALLINT NOT NULL,
  tag_id SMALLINT NOT NULL,
  tag VARCHAR(30) NOT NULL,
  tag_type VARCHAR(20) NOT NULL,
  is_value_required BOOLEAN NOT NULL,
  is_domain_checked BOOLEAN NOT NULL
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS tag FOR TABLE tagzzz;

ALTER TABLE tagzzz
ADD CONSTRAINT tagzzz_pk PRIMARY KEY (document_type_id, tag_id);

ALTER TABLE tagzzz
ADD CONSTRAINT tagzzz_uk1 UNIQUE (document_type_id, tag, tag_type);

ALTER TABLE tagzzz
ADD CONSTRAINT tagzzz_c1 CHECK (tag_id > 0);

ALTER TABLE tagzzz
ADD CONSTRAINT tagzzz_c2 CHECK (tag != '');

ALTER TABLE tagzzz
ADD CONSTRAINT tagzzz_c3 CHECK (tag_type IN ('DOCUMENT', 'EXTERNAL_REFERENCE'));

ALTER TABLE tagzzz
ADD CONSTRAINT tagzzz_c4 CHECK (NOT is_domain_checked OR is_value_required);

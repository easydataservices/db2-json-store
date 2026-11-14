-- EXTERNAL_REFERENCE table
CREATE TABLE extref
(
  external_ref VARCHAR(30) NOT NULL,
  external_ref_type_id SMALLINT NOT NULL
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS external_reference FOR TABLE extref;

ALTER TABLE extref
ADD CONSTRAINT extref_pk PRIMARY KEY (external_ref, external_ref_type_id);

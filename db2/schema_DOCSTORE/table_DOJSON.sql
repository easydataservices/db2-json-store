-- Table DOCUMENT_JSON

CREATE TABLE dojson
(
  document_id BIGINT NOT NULL,
  partition_num SMALLINT NOT NULL,
  json_document CLOB(2M) INLINE LENGTH 32000 NOT NULL
)
  ORGANIZE BY ROW
  PARTITION BY (partition_num)
  (
    STARTING 0 ENDING 0 IN dat_docstore_0 INDEX in idx_docstore_0 LONG IN lob_docstore_0,
    STARTING 1 ENDING 1 IN dat_docstore_1 INDEX in idx_docstore_1 LONG IN lob_docstore_1,
    STARTING 2 ENDING 2 IN dat_docstore_2 INDEX in idx_docstore_2 LONG IN lob_docstore_2,
    STARTING 3 ENDING 3 IN dat_docstore_3 INDEX in idx_docstore_3 LONG IN lob_docstore_3,
    STARTING 4 ENDING 4 IN dat_docstore_4 INDEX in idx_docstore_4 LONG IN lob_docstore_4,
    STARTING 5 ENDING 5 IN dat_docstore_5 INDEX in idx_docstore_5 LONG IN lob_docstore_5,
    STARTING 6 ENDING 6 IN dat_docstore_6 INDEX in idx_docstore_6 LONG IN lob_docstore_6,
    STARTING 7 ENDING 7 IN dat_docstore_7 INDEX in idx_docstore_7 LONG IN lob_docstore_7
  )
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS document_json FOR TABLE dojson;

CREATE UNIQUE INDEX dojson_pk ON dojson(document_id, partition_num) PARTITIONED;

ALTER TABLE dojson ADD CONSTRAINT dojson_pk PRIMARY KEY (document_id, partition_num);

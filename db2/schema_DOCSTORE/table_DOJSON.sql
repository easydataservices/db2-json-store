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

SELECT * FROM document_index;

DOCUMENT_ID          PARTITION_NUM DOCUMENT_TYPE_ID INSERTED_UTC_TS     DELETED_UTC_TS      IS_VALID_JSON EXTERNAL_REF                   EXTERNAL_REF_TYPE_ID
-------------------- ------------- ---------------- ------------------- ------------------- ------------- ------------------------------ --------------------
                   1             2                1 2026-11-15-19.52.11 -                               1 EMPTYDOC                                          1
                   2             3                1 2026-11-15-19.53.03 -                               1 2026v1_ACME                                       1

  2 record(s) selected.

SELECT * FROM external_reference;

EXTERNAL_REF                   EXTERNAL_REF_TYPE_ID
------------------------------ --------------------
EMPTYDOC                                          1
2026v1_ACME                                       1

  2 record(s) selected.

SELECT document_id, partition_num, CAST(json_document AS VARCHAR(80)) AS json_document FROM document_json;

DOCUMENT_ID          PARTITION_NUM JSON_DOCUMENT                                                                   
-------------------- ------------- --------------------------------------------------------------------------------
                   1             2 {}                                                                              
                   2             3 {"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}         

  2 record(s) selected.

SELECT * FROM audit_log;

LOG_ID               LOG_UTC_TS          USER_NAME                                                                                                                        ACTION               DOCUMENT_ID          DOCUMENT_TYPE_ID TAG_ID INDEX_ID
-------------------- ------------------- -------------------------------------------------------------------------------------------------------------------------------- -------------------- -------------------- ---------------- ------ --------
                   1 2026-11-15-19.52.11 JEREMY                                                                                                                           ADD_DOCUMENT                            1                1      -        -
                   2 2026-11-15-19.53.03 JEREMY                                                                                                                           ADD_DOCUMENT                            2                1      -        -

  2 record(s) selected.
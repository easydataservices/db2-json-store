-- Table JSON_INDEX_HISTORY

CREATE TABLE jindhi
(
  index_id SMALLINT NOT NULL,
  start_utc_ts TIMESTAMP(0) NOT NULL,
  operation_type VARCHAR(20) NOT NULL,
  commit_count INTEGER NOT NULL DEFAULT 0,
  row_count BIGINT NOT NULL DEFAULT 0,
  last_commit_utc_ts TIMESTAMP(0) NOT NULL,
  is_complete BOOLEAN NOT NULL DEFAULT FALSE
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS json_index_history FOR TABLE jindhi;

ALTER TABLE jindhi
ADD CONSTRAINT jindhi_pk PRIMARY KEY (index_id, start_utc_ts);

ALTER TABLE jindhi
ADD CONSTRAINT jindhi_c1 CHECK (operation_type IN ('BUILD', 'PURGE'));

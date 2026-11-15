-- AUDIT_LOG table
CREATE TABLE audlog
(
  log_id BIGINT NOT NULL,
  log_utc_ts TIMESTAMP(0) NOT NULL,
  user_name VARCHAR(128) NOT NULL,
  action VARCHAR(20) NOT NULL,
  document_id BIGINT,
  document_type_id SMALLINT,
  tag_id SMALLINT,
  index_id SMALLINT
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  COMPRESS YES
  WITH RESTRICT ON DROP;

CREATE ALIAS audit_log FOR TABLE audlog;

ALTER TABLE audlog
ADD CONSTRAINT audlog_pk PRIMARY KEY (log_id);

ALTER TABLE audlog
ADD CONSTRAINT audlog_c1 CHECK
(
  action IN ('ADD_DOCUMENT')
);

CREATE INDEX audlog_ix1 ON audlog(log_utc_ts);

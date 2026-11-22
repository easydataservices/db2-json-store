-- Table JSON_INDEX_CONTROL

CREATE TABLE jindco
(
  singleton_id SMALLINT NOT NULL,
  build_commit_limit SMALLINT NOT NULL DEFAULT 20,
  build_throttle_rate SMALLINT DEFAULT 50,
  purge_commit_limit SMALLINT NOT NULL DEFAULT 20,
  purge_throttle_rate SMALLINT DEFAULT 50,
  stop_utc_ts TIMESTAMP(0)
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS json_index_control FOR TABLE jindco;

ALTER TABLE jindco
ADD CONSTRAINT jindco_pk PRIMARY KEY (singleton_id);

ALTER TABLE jindco
ADD CONSTRAINT jindco_c1 CHECK (singleton_id = 1);

ALTER TABLE jindco
ADD CONSTRAINT jindco_c2 CHECK (build_commit_limit);

ALTER TABLE jindco
ADD CONSTRAINT jindco_c3 CHECK (build_throttle_rate > 0);

ALTER TABLE jindco
ADD CONSTRAINT jindco_c4 CHECK (purge_commit_limit > 0);

ALTER TABLE jindco
ADD CONSTRAINT jindco_c5 CHECK (purge_throttle_rate > 0);

INSERT INTO json_index_control(singleton_id) VALUES 1;

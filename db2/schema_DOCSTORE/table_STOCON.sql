-- Table STORE_CONTROL

CREATE TABLE stocon
(
  singleton_id SMALLINT NOT NULL,
  total_partitions SMALLINT NOT NULL,
  inactive_partition_num SMALLINT NOT NULL DEFAULT 0,
  is_invalid_json_blocked BOOLEAN NOT NULL DEFAULT TRUE
)
  ORGANIZE BY ROW
  IN dat_docstore INDEX in idx_docstore
  WITH RESTRICT ON DROP;

CREATE ALIAS store_control FOR TABLE stocon;

ALTER TABLE stocon
ADD CONSTRAINT stocon_pk PRIMARY KEY (singleton_id);

ALTER TABLE stocon
ADD CONSTRAINT stocon_c1 CHECK (singleton_id = 1);

ALTER TABLE stocon
ADD CONSTRAINT stocon_c2 CHECK (total_partitions > 1);

ALTER TABLE stocon
ADD CONSTRAINT stocon_c3 CHECK (inactive_partition_num BETWEEN 0 AND total_partitions - 1);

INSERT INTO store_control(singleton_id, total_partitions) VALUES (1, 8);

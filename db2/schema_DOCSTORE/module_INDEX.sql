CREATE OR REPLACE MODULE index;

ALTER MODULE index
ADD TYPE control_row AS ROW
(
  build_commit_limit SMALLINT,
  build_throttle_rate SMALLINT,
  purge_commit_limit SMALLINT,
  purge_throttle_rate SMALLINT,
  is_stop_requested BOOLEAN
);

ALTER MODULE index
ADD TYPE history_row AS ROW(row_count BIGINT, is_complete BOOLEAN);

-- Build an index
ALTER MODULE index
PUBLISH PROCEDURE build_index(p_document_type_id SMALLINT, p_index_name VARCHAR(30));

-- Purge an index
ALTER MODULE index
PUBLISH PROCEDURE purge_index(p_document_type_id SMALLINT, p_index_name VARCHAR(30));

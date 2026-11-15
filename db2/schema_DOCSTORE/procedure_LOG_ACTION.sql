CREATE OR REPLACE PROCEDURE log_action
(
  p_action VARCHAR(20), p_document_id BIGINT, p_document_type_id SMALLINT, p_tag_id SMALLINT, p_index_id SMALLINT
)
BEGIN
  INSERT INTO audit_log(log_id, log_utc_ts, user_name, action, document_id, document_type_id, tag_id, index_id)
  VALUES
    (
      NEXT VALUE FOR log_id,
      CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
      SESSION_USER,
      p_action,
      p_document_id,
      p_document_type_id,
      p_tag_id,
      p_index_id
    );
END@

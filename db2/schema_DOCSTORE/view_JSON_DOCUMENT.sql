CREATE OR REPLACE VIEW json_document
(
  document_id,
  inserted_utc_ts,
  document_type_id,
  external_ref,
  is_valid_json,
  json_document
) AS
SELECT
  i.document_id,
  i.inserted_utc_ts,
  i.document_type_id,
  i.external_ref,
  i.is_valid_json,
  j.json_document
FROM
  document_index AS i
    INNER JOIN
  document_json AS j
    ON
      j.document_id = i.document_id AND
      j.partition_num = i.partition_num AND
      deleted_utc_ts IS NULL;

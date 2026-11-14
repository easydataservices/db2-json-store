CREATE OR REPLACE VIEW json_document
(
  document_id,
  partition_num,
  inserted_utc_ts,
  document_type_id,
  external_ref,
  associated_entity_ref,
  is_valid_json,
  json_document
) AS
SELECT
  i.document_id,
  i.partition_num,
  i.inserted_utc_ts,
  i.document_type_id,
  i.external_ref,
  i.associated_entity_ref,
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

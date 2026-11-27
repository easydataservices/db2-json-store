ALTER MODULE jdoc
ADD FUNCTION get_all_documents(p_document_type_id SMALLINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    inserted_utc_ts TIMESTAMP(0),
    document_type_name VARCHAR(30),
    external_ref VARCHAR(30),
    is_valid_json BOOLEAN,
    json_document CLOB(2M)
  )
RETURN
  SELECT
    d.document_id,
    d.inserted_utc_ts,
    t.document_type_name,
    d.external_ref,
    d.is_valid_json,
    d.json_document
  FROM
    json_document AS d
      INNER JOIN
    document_type AS t
      ON
        t.document_type_id = d.document_type_id
  WHERE
    t.document_type_id = p_document_type_id AND private.is_viewer(t.document_type_id)@

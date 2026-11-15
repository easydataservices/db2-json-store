# db2-json-store
Enterprise repository for storage and retrieval of JSON documents

## Schema build instructions

Connect to database, change to the ``db2`` subdirectory, then:
```
db2 -tvf ./schema_DOCSTORE/set_env.sql
db2 -tf ./schema_DOCSTORE/sequence_DOCUMENT_ID.sql
db2 -tf ./schema_DOCSTORE/sequence_LOG_ID.sql
db2 -tf ./schema_DOCSTORE/table_AUDLOG.sql
db2 -tf ./schema_DOCSTORE/table_STOCON.sql
db2 -tf ./schema_DOCSTORE/table_DOTYTA.sql
db2 -tf ./schema_DOCSTORE/table_EXTREF.sql
db2 -tf ./schema_DOCSTORE/table_DOCTAG.sql
db2 -tf ./schema_DOCSTORE/table_DOCTYP.sql
db2 -tf ./schema_DOCSTORE/table_DOCIND.sql
db2 -tf ./schema_DOCSTORE/table_DOJSON.sql
db2 -tf ./schema_DOCSTORE/view_JSON_DOCUMENT.sql
db2 -td@ -f ./schema_DOCSTORE/function_IS_JSON_DOCUMENT.sql
db2 -td@ -f ./schema_DOCSTORE/function_IS_JSON_ARRAY.sql
db2 -td@ -f ./schema_DOCSTORE/function_IS_INVALID_JSON_BLOCKED.sql
db2 -td@ -f./schema_DOCSTORE/function_GET_PARTITION_NUM.sql
db2 -td@ -f./schema_DOCSTORE/function_GET_JSON_TAGS.sql
db2 -td@ -f./schema_DOCSTORE/procedure_LOG_ACTION.sql
db2 -td@ -f./schema_DOCSTORE/procedure_ADD_JSON_DOCUMENT.sql
```

## Early tests

As the SECADM user:
```
CREATE ROLE add_organisation_document;
DB20000I  The SQL command completed successfully.

GRANT ROLE add_organisation_document TO USER JEREMY;
DB20000I  The SQL command completed successfully.
```

As DBADM user:
```
-- Insert a document type, with role for adding documents
INSERT INTO document_type(document_type_id, document_type_name, add_document_role)
VALUES
  (1, 'Organisation', 'ADD_ORGANISATION_DOCUMENT');
DB20000I  The SQL command completed successfully.

-- Insert permitted document type tags
INSERT INTO document_type_tag(document_type_id, tag_id, tag)
VALUES
  (1, 1, 'Flagged'),
  (1, 2, 'Pending');
DB20000I  The SQL command completed successfully.

CALL add_json_document(NULL, 1, 'EMPTYDOC', null, '{}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 1

  Return Status = 0

CALL add_json_document(NULL, 1, '2026v1_ACME', '["Flagged", "VIP"]', '{"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}');
SQL0438N  Application raised error or warning with diagnostic text: "Invalid 
tag".  SQLSTATE=DS302

CALL add_json_document(NULL, 1, '2026v1_ACME', '["Flagged", "Pending"]', '{"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 11

  Return Status = 0

select * from table(get_json_tags('[1, {"tag" : ["score", 12]}, "age"]'));

```

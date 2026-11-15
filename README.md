# db2-json-store
Enterprise repository for storage and retrieval of JSON documents

## Schema build instructions

Connect to database, change to the ``db2`` subdirectory, then:
```
db2 -tvf ./schema_DOCSTORE/set_env.sql
db2 -tvf ./schema_DOCSTORE/tablespaces.sql
db2 -tf ./schema_DOCSTORE/sequence_DOCUMENT_ID.sql
db2 -tf ./schema_DOCSTORE/sequence_LOG_ID.sql
db2 -tf ./schema_DOCSTORE/table_AUDLOG.sql
db2 -tf ./schema_DOCSTORE/table_STOCON.sql
db2 -tf ./schema_DOCSTORE/table_EXTREF.sql
db2 -tf ./schema_DOCSTORE/table_DOCTYP.sql
db2 -tf ./schema_DOCSTORE/table_DOCIND.sql
db2 -tf ./schema_DOCSTORE/table_DOJSON.sql
db2 -tf ./schema_DOCSTORE/view_JSON_DOCUMENT.sql
db2 -tf ./schema_DOCSTORE/module_PRIVATE.sql
db2 -tf ./schema_DOCSTORE/module_APPUSER.sql
db2 -td@ -f./schema_DOCSTORE/module_PRIVATE/function_GET_PARTITION_NUM.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_INVALID_JSON_BLOCKED.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_JSON_DOCUMENT.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/procedure_LOG_ACTION.sql
db2 -td@ -f ./schema_DOCSTORE/module_APPUSER/procedure_ADD_JSON_DOCUMENT.sql
```

## Early tests

As the SECADM user:
```
CREATE ROLE add_organisation_document;
DB20000I  The SQL command completed successfully.

CREATE ROLE view_organisation_document;
DB20000I  The SQL command completed successfully.

GRANT ROLE add_organisation_document TO USER JEREMY;
DB20000I  The SQL command completed successfully.
```

As DBADM user:
```
-- Insert a document type, with role for adding documents
INSERT INTO document_type(document_type_id, document_type_name, view_document_role, add_document_role)
VALUES
  (1, 'Organisation', 'VIEW_ORGANISATION_DOCUMENT', 'ADD_ORGANISATION_DOCUMENT');
DB20000I  The SQL command completed successfully.

CALL appuser.add_json_document(NULL, 1, 'EMPTYDOC', null, '{}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 1

  Return Status = 0

CALL appuser.add_json_document(NULL, 1, '2026v1_ACME', null, '{"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 2

  Return Status = 0

```

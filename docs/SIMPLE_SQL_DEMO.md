# db2-json-store simple demo with SQL API

This page shows some simple usage examples using the SQL API. For further details of supported procedures and functions see [module_JDOC.sql](../db2/schema_DOCSTORE/module_JDOC.sql) and [module_INFO.sql](../db2/schema_DOCSTORE/module_INFO.sql).

See also:
  * [README.md](../README.md)

---

In these examples, the database security administrator (SECADM) user creates and assigns roles to user JEREMY. An admin user configures a document type, specifying the new roles to allow insertion, deletion and retrieval of documents of that document type. User JEREMY then adds, views and removes various JSON documents in the document store.

## Create security roles

As the SECADM user, create security roles for an Organisation document type:
```
CREATE ROLE add_organisation_doc;
DB20000I  The SQL command completed successfully.

CREATE ROLE remove_organisation_doc;
DB20000I  The SQL command completed successfully.

CREATE ROLE view_organisation_doc;
DB20000I  The SQL command completed successfully.

GRANT ROLE add_organisation_doc TO USER JEREMY;
DB20000I  The SQL command completed successfully.

GRANT ROLE remove_organisation_doc TO USER JEREMY;
DB20000I  The SQL command completed successfully.

GRANT ROLE view_organisation_doc TO USER JEREMY;
DB20000I  The SQL command completed successfully.
```

## Add organisation document type

As the admin user, add a new Organisation document type:
```
CALL admin.add_document_type(1, 'Organisation', 'VIEW_ORGANISATION_DOC', 'ADD_ORGANISATION_DOC', 'REMOVE_ORGANISATION_DOC');

  Return Status = 0
```

## Add and retrieve JSON documents

This section shows a few different scenarios and features.

As user JEREMY:
```
-- Add a document
CALL jdoc.add_document(NULL, 1, '2026v1_ACME', null, '{"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 1

  Return Status = 0

-- Add another document
CALL jdoc.add_document(NULL, 1, '2025v1_CleanFresh', null, '{"name" : "Clean & Fresh Grocers", "sector" : "Supermarket", "account_num" : 8213}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 2

  Return Status = 0

-- Retrieve a document
SELECT
  document_id,
  inserted_utc_ts,
  document_type_name,
  external_ref,
  cast(json_document AS VARCHAR(85)) AS json_document
FROM
  TABLE(jdoc.get_document(1));

DOCUMENT_ID          INSERTED_UTC_TS     DOCUMENT_TYPE_NAME             EXTERNAL_REF                   JSON_DOCUMENT                                                                        
-------------------- ------------------- ------------------------------ ------------------------------ -------------------------------------------------------------------------------------
                   1 2026-11-27-05.42.28 Organisation                   2026v1_ACME                    {"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}              

  1 record(s) selected

-- Remove a document
CALL jdoc.remove_document(1);

  Return Status = 0

-- Retrieve a document
SELECT
  document_id,
  inserted_utc_ts,
  document_type_name,
  external_ref,
  cast(json_document AS VARCHAR(85)) AS json_document
FROM
  TABLE(jdoc.get_document(2));

DOCUMENT_ID          INSERTED_UTC_TS     DOCUMENT_TYPE_NAME             EXTERNAL_REF                   JSON_DOCUMENT                                                                        
-------------------- ------------------- ------------------------------ ------------------------------ -------------------------------------------------------------------------------------
                   2 2026-11-27-05.42.45 Organisation                   2025v1_CleanFresh              {"name" : "Clean & Fresh Grocers", "sector" : "Supermarket", "account_num" : 8213}   

  1 record(s) selected.

-- Retrieve the removed document
SELECT
  document_id,
  inserted_utc_ts,
  document_type_name,
  external_ref,
  cast(json_document AS VARCHAR(85)) AS json_document
FROM
  TABLE(jdoc.get_document(1));

DOCUMENT_ID          INSERTED_UTC_TS     DOCUMENT_TYPE_NAME             EXTERNAL_REF                   JSON_DOCUMENT                                                                        
-------------------- ------------------- ------------------------------ ------------------------------ -------------------------------------------------------------------------------------

  0 record(s) selected.

-- Attempt to add an updated document for organisation name change, using duplicate reference 
CALL jdoc.add_document(NULL, 1, '2025v1_CleanFresh', null, '{"name" : "Clean & Fresh", "sector" : "Supermarket", "account_num" : 8213}');
SQL0438N  Application raised error or warning with diagnostic text: 
"Disallowed duplicate EXTERNAL_REF".  SQLSTATE=DS301
```

As admin user:
```
-- Allow duplicate external references for the document type
CALL admin.set_duplicate_external_ref_blocked(1, FALSE);

  Return Status = 0
```
> Note: Reversing this change will not only block further duplicates; any existing duplicates will remain.

As user JEREMY:
```
-- Attempt to add an updated document for organisation name change, using duplicate reference 
CALL jdoc.add_document(NULL, 1, '2025v1_CleanFresh', null, '{"name" : "Clean & Fresh", "sector" : "Supermarket", "account_num" : 8213}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 3

  Return Status = 0

-- Attempt to add a document with incorrect JSON
CALL jdoc.add_document(NULL, 1, 'myBadJson', null, '{"name" : "Bad Boyz Inc", "sector" : bogus}');
SQL0438N  Application raised error or warning with diagnostic text: "Invalid 
JSON document".  SQLSTATE=DS201
```

As admin user:
```
-- Change the document store settings to permit incorrect JSON
CALL admin.set_invalid_json_blocked(FALSE);
DB20000I  The SQL command completed successfully.

  Return Status = 0
```

As user JEREMY:
```
-- Attempt to add a document with incorrect JSON
CALL jdoc.add_document(NULL, 1, 'myBadJson', null, '{"name" : "Bad Boyz Inc", "sector" : bogus}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 4

  Return Status = 0
```

As admin user:
```
-- Query the index table of documents:
SELECT document_id, inserted_utc_ts, document_type_name, external_ref, is_valid_json, CAST(json_document AS VARCHAR(85)) AS json_document FROM TABLE(jdoc.get_all_documents(1));

DOCUMENT_ID          INSERTED_UTC_TS     DOCUMENT_TYPE_NAME             EXTERNAL_REF                   IS_VALID_JSON JSON_DOCUMENT                                                                        
-------------------- ------------------- ------------------------------ ------------------------------ ------------- -------------------------------------------------------------------------------------
                   2 2026-11-27-05.42.45 Organisation                   2025v1_CleanFresh                          1 {"name" : "Clean & Fresh Grocers", "sector" : "Supermarket", "account_num" : 8213}   
                   3 2026-11-27-05.45.21 Organisation                   2025v1_CleanFresh                          1 {"name" : "Clean & Fresh", "sector" : "Supermarket", "account_num" : 8213}           
                   4 2026-11-27-05.45.49 Organisation                   myBadJson                                  0 {"name" : "Bad Boyz Inc", "sector" : bogus}                                          

  3 record(s) selected.
```

## Check audit log

```
SELECT
  log_id, log_utc_ts, CAST(user_name AS VARCHAR(20)) AS user_name, action, document_id, document_type_id, tag_id, index_id
FROM
  audit_log
ORDER BY
  log_id;

LOG_ID               LOG_UTC_TS          USER_NAME            ACTION                         DOCUMENT_ID          DOCUMENT_TYPE_ID TAG_ID INDEX_ID
-------------------- ------------------- -------------------- ------------------------------ -------------------- ---------------- ------ --------
                   1 2026-11-27-05.41.39 JEREMY               ADD_DOCUMENT_TYPE                                 -                1      -        -
                   2 2026-11-27-05.42.28 JEREMY               ADD_DOCUMENT                                      1                1      -        -
                   3 2026-11-27-05.42.45 JEREMY               ADD_DOCUMENT                                      2                1      -        -
                   4 2026-11-27-05.43.51 JEREMY               REMOVE_DOCUMENT                                   1                1      -        -
                   5 2026-11-27-05.45.10 JEREMY               ALLOW_DUPLICATE_REF                               -                1      -        -
                   6 2026-11-27-05.45.21 JEREMY               ADD_DOCUMENT                                      3                1      -        -
                   7 2026-11-27-05.45.39 JEREMY               ALLOW_INVALID_JSON                                -                -      -        -
                   8 2026-11-27-05.45.49 JEREMY               ADD_DOCUMENT                                      4                1      -        -

  8 record(s) selected.
```

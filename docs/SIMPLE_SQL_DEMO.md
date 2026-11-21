# db2-json-store simple SQL demo

This page shows some simple usage examples using only SQL.

See also:
  * [README.md](../README.md)

---

In these examples, the database security administrator (SECADM) user creates and assigns roles to user JEREMY. An admin user configures a document type, specifying the new roles to allow insertion, deletion and retrieval of documents of that document type. User JEREMY then adds, views and removes various JSON documents in the document store.

## Create security roles

As the SECADM user:
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

As admin user:
```
-- Insert a document type, with role for adding documents
INSERT INTO document_type(document_type_id, document_type_name, view_document_role, add_document_role, remove_document_role)
VALUES
  (1, 'Organisation', 'VIEW_ORGANISATION_DOC', 'ADD_ORGANISATION_DOC', 'REMOVE_ORGANISATION_DOC');
DB20000I  The SQL command completed successfully.
```

## Add and retrieve JSON documents

This section shows a few different scenarios and features.

As user JEREMY:
```
-- Add a document
CALL docuser.add_json_document(NULL, 1, '2026v1_ACME', null, '{"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 1

  Return Status = 0

-- Add another document
CALL docuser.add_json_document(NULL, 1, '2025v1_CleanFresh', null, '{"name" : "Clean & Fresh Grocers", "sector" : "Supermarket", "account_num" : 8213}');

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
  TABLE(docuser.get_json_document(1));

DOCUMENT_ID          INSERTED_UTC_TS     DOCUMENT_TYPE_NAME             EXTERNAL_REF                   JSON_DOCUMENT                                                                        
-------------------- ------------------- ------------------------------ ------------------------------ -------------------------------------------------------------------------------------
                   1 2026-11-16-18.38.58 Organisation                   2026v1_ACME                    {"name" : "ACME Corp", "sector" : "Conglomerate", "account_num" : 1234}         

  1 record(s) selected.

-- Remove a document
CALL docuser.remove_json_document(1);

  Return Status = 0

-- Retrieve a document
SELECT
  document_id,
  inserted_utc_ts,
  document_type_name,
  external_ref,
  cast(json_document AS VARCHAR(85)) AS json_document
FROM
  TABLE(docuser.get_json_document(2));

DOCUMENT_ID          INSERTED_UTC_TS     DOCUMENT_TYPE_NAME             EXTERNAL_REF                   JSON_DOCUMENT                                                                        
-------------------- ------------------- ------------------------------ ------------------------------ -------------------------------------------------------------------------------------
                   2 2026-11-16-18.39.05 Organisation                   2025v1_CleanFresh              {"name" : "Clean & Fresh Grocers", "sector" : "Supermarket", "account_num" : 8213}   

  1 record(s) selected.

-- Retrieve the removed document
SELECT
  document_id,
  inserted_utc_ts,
  document_type_name,
  external_ref,
  cast(json_document AS VARCHAR(85)) AS json_document
FROM
  TABLE(docuser.get_json_document(1));

DOCUMENT_ID          INSERTED_UTC_TS     DOCUMENT_TYPE_NAME             EXTERNAL_REF                   JSON_DOCUMENT                                                                        
-------------------- ------------------- ------------------------------ ------------------------------ -------------------------------------------------------------------------------------

  0 record(s) selected.

-- Attempt to add an updated document for organisation name change, using duplicate reference 
CALL docuser.add_json_document(NULL, 1, '2025v1_CleanFresh', null, '{"name" : "Clean & Fresh", "sector" : "Supermarket", "account_num" : 8213}');
SQL0438N  Application raised error or warning with diagnostic text: 
"Disallowed duplicate EXTERNAL_REF".  SQLSTATE=DS301
```

As admin user:
```
-- Allow duplicate external references for the document type
UPDATE document_type SET is_duplicate_external_ref_blocked = FALSE WHERE document_type_id = 1;
DB20000I  The SQL command completed successfully.
```
> Note: Reversing this change will not only block further duplicates; any existing duplicates will remain.

As user JEREMY:
```
-- Attempt to add an updated document for organisation name change, using duplicate reference 
CALL docuser.add_json_document(NULL, 1, '2025v1_CleanFresh', null, '{"name" : "Clean & Fresh", "sector" : "Supermarket", "account_num" : 8213}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 3

  Return Status = 0

-- Attempt to add a document with incorrect JSON
CALL docuser.add_json_document(NULL, 1, 'myBadJson', null, '{"name" : "Bad Boyz Inc", "sector" : bogus}');
SQL0438N  Application raised error or warning with diagnostic text: "Invalid 
JSON document".  SQLSTATE=DS201
```

As admin user:
```
-- Change the document store settings to permit incorrect JSON
UPDATE store_control SET is_invalid_json_blocked = FALSE;
DB20000I  The SQL command completed successfully.
```

As user JEREMY:
```
-- Attempt to add a document with incorrect JSON
CALL docuser.add_json_document(NULL, 1, 'myBadJson', null, '{"name" : "Bad Boyz Inc", "sector" : bogus}');

  Value of output parameters
  --------------------------
  Parameter Name  : P_DOCUMENT_ID
  Parameter Value : 4

  Return Status = 0
```

As admin user:
```
-- Query the index table of documents:
SELECT * FROM document_index;

DOCUMENT_ID          PARTITION_NUM DOCUMENT_TYPE_ID INSERTED_UTC_TS     DELETED_UTC_TS      IS_VALID_JSON EXTERNAL_REF                   EXTERNAL_REF_TYPE_ID
-------------------- ------------- ---------------- ------------------- ------------------- ------------- ------------------------------ --------------------
                   1             2                1 2026-11-16-18.38.58 2026-11-16-18.50.47             1 2026v1_ACME                                       1
                   2             3                1 2026-11-16-18.39.05 -                               1 2025v1_CleanFresh                                 1
                   3             4                1 2026-11-16-19.02.30 -                               1 2025v1_CleanFresh                                 1
                   4             5                1 2026-11-16-19.12.50 -                               0 myBadJson                                         1

  4 record(s) selected.
```

# db2-json-store JSON indexing demo

This page demonstrates JSON indexing features.

See also:
  * [README.md](../README.md)

## Create new security roles

As the SECADM user:
```
CREATE ROLE add_payment_doc;
DB20000I  The SQL command completed successfully.

CREATE ROLE remove_payment_doc;
DB20000I  The SQL command completed successfully.

CREATE ROLE view_payment_doc;
DB20000I  The SQL command completed successfully.

GRANT ROLE add_payment_doc TO USER JEREMY;
DB20000I  The SQL command completed successfully.

GRANT ROLE view_payment_doc TO USER JEREMY;
DB20000I  The SQL command completed successfully.
```

## Add payment document type

As admin user:
```
-- Insert a new document type for payments
INSERT INTO document_type(document_type_id, document_type_name, view_document_role, add_document_role, remove_document_role)
VALUES
  (2, 'Payment', 'VIEW_PAYMENT_DOC', 'ADD_PAYMENT_DOC', 'REMOVE_PAYMENT_DOC');
DB20000I  The SQL command completed successfully.
```

## Create some sample data

This section shows a few different scenarios and features.

As user JEREMY:
```
-- Add some payments
BEGIN
  DECLARE v_bigint BIGINT;
  FOR r AS
    WITH t(i) AS (VALUES 1 UNION ALL SELECT i + 1 FROM t WHERE i < 100) SELECT i FROM t
  DO
    CALL docuser.add_json_document(v_bigint, 2, NULL, NULL, '{"account_num" : ' || r.i || ', "amount" : ' || r.i || '.49, "description" : "Monthly interest"}');
    SET v_bigint = NULL;
  END FOR;
END@
DB20000I  The SQL command completed successfully

CALL admin.add_json_index('ACCOUNT_NUM', 2, 'strict $.account_num', 'BIGINT', ?);

  Value of output parameters
  --------------------------
  Parameter Name  : P_INDEX_ID
  Parameter Value : 1

  Return Status = 0

BEGIN
  DECLARE v_bigint BIGINT;
  FOR r AS
    WITH t(i) AS (VALUES 51 UNION ALL SELECT i + 1 FROM t WHERE i < 150) SELECT i FROM t
  DO
    CALL docuser.add_json_document(v_bigint, 2, NULL, NULL, '{"account_num" : ' || r.i || ', "amount" : ' || -r.i || '.01, "description" : "Fee"}');
    SET v_bigint = NULL;
  END FOR;
END@
DB20000I  The SQL command completed successfully

```

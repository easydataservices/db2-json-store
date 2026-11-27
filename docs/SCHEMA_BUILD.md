# db2-json-store schema build instructions

This page describes how to create all schema objects from the Db2 command line.

See also:
  * [README.md](../README.md)

## Prerequisites

Connect to database as an appropriate administrative user.

Change to the ``db2`` subdirectory, then:
```
db2 -tvf ./schema_DOCSTORE/set_env.sql
db2 -tvf ./schema_DOCSTORE/tablespaces.sql
```

## Tables and views

These commands all tables, views and sequences:
```
db2 -tf ./schema_DOCSTORE/table_AUDLOG.sql
db2 -tf ./schema_DOCSTORE/table_STOCON.sql
db2 -tf ./schema_DOCSTORE/table_EXTREF.sql
db2 -tf ./schema_DOCSTORE/table_DOCTYP.sql
db2 -tf ./schema_DOCSTORE/table_DOCIND.sql
db2 -tf ./schema_DOCSTORE/table_DOJSON.sql
db2 -tf ./schema_DOCSTORE/table_JINDEX.sql
db2 -tf ./schema_DOCSTORE/table_JBIGIV.sql
db2 -tf ./schema_DOCSTORE/table_JDBLIV.sql
db2 -tf ./schema_DOCSTORE/table_JSTRIV.sql
db2 -tf ./schema_DOCSTORE/table_JINDCO.sql
db2 -tf ./schema_DOCSTORE/table_JINDHI.sql

db2 -tf ./schema_DOCSTORE/view_JSON_DOCUMENT.sql

db2 -tf ./schema_DOCSTORE/sequence_DOCUMENT_ID.sql
db2 -tf ./schema_DOCSTORE/sequence_LOG_ID.sql
```

## Core components

The following commands create core modules needed for saving and retrieval JSON documents, also to support other optional functionality:
```
db2 -tf ./schema_DOCSTORE/module_PRIVATE.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_GET_PARTITION_NUM.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_INVALID_JSON_BLOCKED.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_JSON_DOCUMENT.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_NEW_EXTERNAL_REF.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_JSON_PATH.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_TIDY_JSON_PATH.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_ADDER.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_REMOVER.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/function_IS_VIEWER.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/procedure_ADD_INDEX_BIGINT_ENTRY.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/procedure_ADD_INDEX_DOUBLE_ENTRY.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/procedure_ADD_INDEX_VARCHAR_ENTRY.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/procedure_ADD_INDEX_ENTRY.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/procedure_REMOVE_INDEX_ENTRY.sql
db2 -td@ -f ./schema_DOCSTORE/module_PRIVATE/procedure_LOG_ACTION.sql

db2 -tf ./schema_DOCSTORE/module_JDOC.sql
db2 -td@ -f ./schema_DOCSTORE/module_JDOC/procedure_ADD_DOCUMENT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JDOC/procedure_REMOVE_DOCUMENT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JDOC/function_GET_DOCUMENT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JDOC/function_GET_ALL_DOCUMENTS.sql

db2 -tf ./schema_DOCSTORE/module_ADMIN.sql
db2 -td@ -f ./schema_DOCSTORE/module_ADMIN/procedure_ADD_DOCUMENT_TYPE.sql
db2 -td@ -f ./schema_DOCSTORE/module_ADMIN/procedure_SET_INVALID_JSON_BLOCKED.sql
db2 -td@ -f ./schema_DOCSTORE/module_ADMIN/procedure_SET_DUPLICATE_EXTERNAL_REF_BLOCKED.sql

db2 -tf ./schema_DOCSTORE/module_INFO.sql
db2 -td@ -f ./schema_DOCSTORE/module_INFO/function_DOCUMENT_TYPE_ID.sql
db2 -td@ -f ./schema_DOCSTORE/module_INFO/function_DOCUMENT_TYPE_NAME.sql
db2 -td@ -f ./schema_DOCSTORE/module_INFO/function_GET_INDEXES.sql
```

## Indexing components

Execute these commands to add JSON indexing support.
```
db2 -tf ./schema_DOCSTORE/module_INDEXER.sql
db2 -td@ -f ./schema_DOCSTORE/module_INDEXER/procedure_UPDATE_METADATA.sql
db2 -td@ -f ./schema_DOCSTORE/module_INDEXER/procedure_BUILD_INDEX.sql
db2 -td@ -f ./schema_DOCSTORE/module_INDEXER/procedure_PURGE_INDEX.sql

db2 -td@ -f ./schema_DOCSTORE/module_ADMIN/procedure_ADD_INDEX.sql
db2 -td@ -f ./schema_DOCSTORE/module_ADMIN/procedure_REMOVE_INDEX.sql

db2 -tf ./schema_DOCSTORE/module_JINDEX.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_USABLE_INDEX_ID.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_UNINDEXED_BIGINT_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_UNINDEXED_DOUBLE_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_UNINDEXED_STRING_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_BIGINT_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_BIGINT_VALUES_EQ.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_BIGINT_VALUES_GE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_BIGINT_VALUES_GT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_BIGINT_VALUES_LE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_BIGINT_VALUES_LT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_BIGINT_VALUES_BETWEEN.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_DOUBLE_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_DOUBLE_VALUES_EQ.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_DOUBLE_VALUES_GE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_DOUBLE_VALUES_GT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_DOUBLE_VALUES_LE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_DOUBLE_VALUES_LT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_DOUBLE_VALUES_BETWEEN.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES_EQ.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES_GE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES_GT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES_LE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES_LT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES_BETWEEN.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_INDEXED_STRING_VALUES_LIKE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_BIGINT_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_BIGINT_VALUES_EQ.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_BIGINT_VALUES_GE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_BIGINT_VALUES_GT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_BIGINT_VALUES_LE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_BIGINT_VALUES_LT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_BIGINT_VALUES_BETWEEN.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_DOUBLE_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_DOUBLE_VALUES_EQ.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_DOUBLE_VALUES_GE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_DOUBLE_VALUES_GT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_DOUBLE_VALUES_LE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_DOUBLE_VALUES_LT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_DOUBLE_VALUES_BETWEEN.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES_EQ.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES_GE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES_GT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES_LE.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES_LT.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES_BETWEEN.sql
db2 -td@ -f ./schema_DOCSTORE/module_JINDEX/function_GET_STRING_VALUES_LIKE.sql
```

# db2-json-store

Enterprise repository for storage and retrieval of JSON documents.

## Overview

The objective is a generic JSON document store designed with low maintenance in mind, hosted in a Db2 for LUW database and meeting multiple criteria:

* Heterogenous: Stores different types of JSON document (i.e. with different schemas) in the same store
  * Adding a new type of JSON document requires no new tables
* Multi-tenancy: Fine-grain access control determines who can read and write JSON documents of a particular type
* Correctness: Only syntactically correct JSON can be stored
  * Or if users permit incorrect JSON to be stored, it is automatically flagged as invalid
* Faithfulness: JSON is stored as text, not converted to BSON
  * Avoids inaccurate decimal fractions caused by BSON floating-point storage
* Flexibility: Single documents up to 2MB can be stored
  * Limit is arbitrary; a custom implementation can store much larger documents (theoretical maximum 2GB)
* Scalability: Standard implementation supports _minimum_ limit of 32TB of JSON documents in a single database
  * Limit applies only LOB storage holding documents larger than 32000 bytes
  * Smaller documents are held with regular table data and do not count towards the limit; furthermore they are compressed
  * By adding data partitions in a custom implementation, the LOB storage limit can be increased (theoretical maximum 128PB)
* Performance:
  * Document writes designed to avoid contention and possble LOB fragmentation
  * Ability to index JSON for faster searching
* Maintenance:
  * Optimised to avoid the need for table reorgs 
  * LOBs inlined when possible, and compressed for smaller storage footprint
  * Round-robin writes avoid partition size skew

> Note: It is intended to add a document tagging feature and Java API in future releases.

## Schema build instructions

The page contains instructions for building the schema in a new database. See [docs/SCHEMA_BUILD.md](docs/SCHEMA_BUILD.md).

## Simple demo with SQL API

Basic functionality for storing and retrieving JSON documents. See [docs/SIMPLE_SQL_DEMO.md](docs/SIMPLE_SQL_DEMO.md).

## JSON indexing demo with SQL API

Support for indexing values held in the stored JSON documents. See [docs/INDEXING_DEMO.md](docs/INDEXING_DEMO.md).

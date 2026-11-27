CREATE OR REPLACE MODULE jindex;

-- Retrieve JSON BIGINT values for the specified document type and JSON path
ALTER MODULE jindex
PUBLISH FUNCTION get_bigint_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

-- Retrieve JSON DOUBLE values for the specified document type and JSON path
ALTER MODULE jindex
PUBLISH FUNCTION get_double_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value DOUBLE
  );

-- Retrieve JSON VARCHAR values for the specified document type and JSON path
ALTER MODULE jindex
PUBLISH FUNCTION get_string_values(p_document_type_id SMALLINT, p_json_path VARCHAR(1000))
  RETURNS TABLE
  (
    document_id BIGINT,
    value VARCHAR(1000)
  );

-- Retrieve document identifiers and BIGINT values for specified JSON path and specified value
ALTER MODULE jindex
PUBLISH FUNCTION get_bigint_values_eq(p_document_type_id SMALLINT, p_json_path VARCHAR(1000), p_value BIGINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

-- Retrieve document identifiers and BIGINT values for specified JSON path and greater than to specified value
ALTER MODULE jindex
PUBLISH FUNCTION get_bigint_values_gt(p_document_type_id SMALLINT, p_json_path VARCHAR(1000), p_value BIGINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

-- Retrieve document identifiers and BIGINT values for specified JSON path and less than to specified value
ALTER MODULE jindex
PUBLISH FUNCTION get_bigint_values_lt(p_document_type_id SMALLINT, p_json_path VARCHAR(1000), p_value BIGINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

-- Retrieve document identifiers and BIGINT values for specified JSON path and greater than or equal to specified value
ALTER MODULE jindex
PUBLISH FUNCTION get_bigint_values_ge(p_document_type_id SMALLINT, p_json_path VARCHAR(1000), p_value BIGINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

-- Retrieve document identifiers and BIGINT values for specified JSON path and less than or equal to specified value
ALTER MODULE jindex
PUBLISH FUNCTION get_bigint_values_le(p_document_type_id SMALLINT, p_json_path VARCHAR(1000), p_value BIGINT)
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

-- Retrieve document identifiers and BIGINT values for specified JSON path and between the specified values
ALTER MODULE jindex
PUBLISH FUNCTION get_bigint_values_between
(
  p_document_type_id SMALLINT, p_json_path VARCHAR(1000), p_min_value BIGINT, p_max_value BIGINT
)
  RETURNS TABLE
  (
    document_id BIGINT,
    value BIGINT
  );

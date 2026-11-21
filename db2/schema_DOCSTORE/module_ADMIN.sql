CREATE OR REPLACE MODULE admin;

-- Add an index
ALTER MODULE admin
PUBLISH PROCEDURE add_json_index
(
  p_index_name VARCHAR(30),
  p_document_type_id SMALLINT,
  p_json_path VARCHAR(1000),
  p_value_data_type VARCHAR(20),
  OUT p_index_id SMALLINT
);

-- Remove an index
ALTER MODULE admin
PUBLISH PROCEDURE remove_json_index
(
  p_index_name VARCHAR(30)
);

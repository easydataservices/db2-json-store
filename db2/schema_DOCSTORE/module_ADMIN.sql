CREATE OR REPLACE MODULE admin;

ALTER MODULE admin
PUBLISH PROCEDURE define_json_index
(
  p_index_name VARCHAR(30), p_document_type_id SMALLINT, p_json_path VARCHAR(2000), OUT p_index_id SMALLINT
);

ALTER MODULE admin
PUBLISH PROCEDURE delete_json_index(p_index_name VARCHAR(30));

CREATE OR REPLACE FUNCTION get_partition_num(p_document_id BIGINT) RETURNS SMALLINT
BEGIN
  DECLARE v_total_partitions SMALLINT;
  DECLARE v_inactive_partition_num SMALLINT;
  DECLARE v_partition_num SMALLINT;
  
  -- Get partitioning control values
  SET (v_total_partitions, v_inactive_partition_num) =
    (SELECT total_partitions, inactive_partition_num FROM store_control WITH CS);
  IF v_total_partitions IS NULL THEN
    SIGNAL SQLSTATE 'DS801' SET MESSAGE_TEXT = 'Missing STORE_CONTROL row';
  END IF;

  -- Calculate and return partition_number
  SET v_partition_num = MOD(p_document_id, v_total_partitions - 1);
  IF v_partition_num >= v_inactive_partition_num THEN
    SET v_partition_num = v_partition_num + 1;
  END IF;
  RETURN v_partition_num;
END@

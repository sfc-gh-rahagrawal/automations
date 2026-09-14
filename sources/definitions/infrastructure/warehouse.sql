-- DCM Project: Warehouse definition
-- General compute warehouse for semantic view operations

DEFINE WAREHOUSE COMPUTE_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  COMMENT = 'General compute warehouse for semantic view operations';

-- Deploy: Compute warehouse
-- Executed via: EXECUTE IMMEDIATE FROM @AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/infrastructure/warehouse.sql

CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  COMMENT = 'General compute warehouse for semantic view operations';

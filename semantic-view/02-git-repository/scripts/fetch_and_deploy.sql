-- Fetch and Deploy: End-to-end orchestration
-- Run this script to pull the latest changes from GitHub and deploy all objects in order.

USE ROLE ACCOUNTADMIN;
USE DATABASE COLES_RETAIL_DB;

-- Step 1: Fetch latest changes from GitHub
ALTER GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO FETCH;

-- Step 2: Infrastructure (schema, warehouse)
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/infrastructure/schema.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/infrastructure/warehouse.sql;

-- Step 3: Tables
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/tables/fact_sales_transactions.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/tables/dim_suppliers.sql;

-- Step 4: Views
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/views/v_stores.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/views/v_product_master.sql;

-- Step 5: Semantic view
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/semantic/deploy_semantic_view.sql;

-- Step 6: Verify
DESCRIBE SEMANTIC VIEW COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL;

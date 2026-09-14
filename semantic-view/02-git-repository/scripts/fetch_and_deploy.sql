-- Fetch and Deploy: End-to-end orchestration
-- Deploys all objects in dependency order: tables -> views -> semantic view

USE ROLE ACCOUNTADMIN;
USE DATABASE COLES_RETAIL_DB;

-- Step 1: Fetch latest changes from GitHub
ALTER GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO FETCH;

-- Step 2: Tables (core, retail, supply_chain, marketing)
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/core/tables/dim_time.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/retail/tables/fact_sales_transactions.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/retail/tables/fact_daily_store_performance.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/supply_chain/tables/dim_suppliers.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/supply_chain/tables/fact_inventory_alerts.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/marketing/tables/fact_customer_reviews.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/marketing/tables/fact_support_tickets.sql;

-- Step 3: Views (ai_analytics, marketing)
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/ai_analytics/views/v_stores.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/ai_analytics/views/v_product_master.sql;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/marketing/views/reviews_sentiment_categories.sql;

-- Step 4: Semantic view
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/coles_retail_db/ai_analytics/semantic/coles_retail_semantic_model.sql;

-- Step 5: Verify
DESCRIBE SEMANTIC VIEW COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL;

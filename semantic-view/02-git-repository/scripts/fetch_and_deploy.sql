-- =============================================================================
-- Fetch and Deploy: End-to-end orchestration
-- =============================================================================
-- Run this script to pull the latest changes from GitHub and deploy the
-- semantic view in one step. Can be scheduled via a Snowflake Task.
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE COLES_RETAIL_DB;
USE SCHEMA AI_ANALYTICS;

-- Step 1: Fetch latest changes from GitHub
ALTER GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO FETCH;

-- Step 2: Deploy the semantic view from the repo
EXECUTE IMMEDIATE FROM
  @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/deploy_semantic_view.sql;

-- Step 3: Verify deployment
DESCRIBE SEMANTIC VIEW COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL;

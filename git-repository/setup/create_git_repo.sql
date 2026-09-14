-- =============================================================================
-- Option 2: Snowflake Git Repository Setup
-- =============================================================================
-- This script creates a Git Repository object in Snowflake that connects to
-- the GitHub repo. Once set up, you can deploy semantic views by running
-- EXECUTE IMMEDIATE FROM @repo/branches/main/...
--
-- Prerequisites:
--   - A GitHub PAT stored as a Snowflake secret
--   - An API integration allowing access to your GitHub org
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE COLES_RETAIL_DB;
USE SCHEMA AI_ANALYTICS;

-- Step 1: The secret and API integration should already exist.
-- If not, create them:

-- CREATE OR REPLACE SECRET DB_GOVERNANCE.REPO.GITHUB_SECRET_TOKEN
--   TYPE = PASSWORD
--   USERNAME = 'sfc-gh-rahagrawal'
--   PASSWORD = '<your-github-pat>';

-- CREATE OR REPLACE API INTEGRATION GITHUB_API_INTEGRATION
--   API_PROVIDER = GIT_HTTPS_API
--   API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-rahagrawal')
--   ALLOWED_AUTHENTICATION_SECRETS = (DB_GOVERNANCE.REPO.GITHUB_SECRET_TOKEN)
--   ENABLED = TRUE;

-- Step 2: Create the Git Repository object
CREATE OR REPLACE GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO
  API_INTEGRATION = GITHUB_API_INTEGRATION
  GIT_CREDENTIALS = DB_GOVERNANCE.REPO.GITHUB_SECRET_TOKEN
  ORIGIN = 'https://github.com/sfc-gh-rahagrawal/automations.git';

-- Step 3: Fetch latest from remote
ALTER GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO FETCH;

-- Step 4: Verify setup
SHOW GIT BRANCHES IN COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO;
LS @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/;

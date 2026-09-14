-- Deploy: Schema for AI Analytics
-- Executed via: EXECUTE IMMEDIATE FROM @AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/infrastructure/schema.sql

CREATE SCHEMA IF NOT EXISTS COLES_RETAIL_DB.AI_ANALYTICS
  COMMENT = 'Analytics schema for semantic views and AI-enriched data';

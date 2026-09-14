# Semantic View DevOps Deployment Demo

Automated deployment of Snowflake Semantic Views using three different DevOps approaches, demonstrated with the **Coles Retail Semantic Model**.

## Overview

This repository contains working examples of three deployment approaches for Snowflake semantic views.

| Approach | Type | Multi-Env | CI/CD | Best For |
|----------|------|-----------|-------|----------|
| [DCM Projects](#option-1-dcm-projects) | Snowflake-native IaC | Jinja templating | `snow dcm plan/deploy` | Teams wanting declarative infrastructure |
| [Snowflake Git Repo](#option-2-snowflake-git-repository) | Snowflake-native Git | Branches/tags | `EXECUTE IMMEDIATE FROM` | No external CI tools needed |
| [GitHub Actions](#option-3-github-actions) | External CI/CD | Branch-based | GitHub Actions workflows | Teams with existing GitHub workflows |

## Repository Structure

```
automations/
├── manifest.yml                          # DCM project manifest (at root for Snowsight)
├── sources/                              # DCM DEFINE statements
│   └── definitions/
│       ├── coles_retail_db/              # Organized by database/schema/object-type
│       │   ├── ai_analytics/
│       │   │   ├── semantic/semantic_view.sql
│       │   │   └── views/v_stores.sql, v_product_master.sql
│       │   ├── core/tables/dim_time.sql
│       │   ├── retail/tables/fact_*.sql
│       │   ├── supply_chain/tables/*.sql
│       │   └── marketing/tables/*.sql, views/*.sql
│       ├── infrastructure/schema.sql, warehouse.sql
│       └── grants/analyst_role.sql
│
├── git-repository/                       # Snowflake Git Repo approach
│   ├── setup/create_git_repo.sql         # One-time Git Repository object setup
│   ├── deploy/coles_retail_db/           # CREATE OR REPLACE statements
│   └── scripts/fetch_and_deploy.sql      # Orchestration script
│
├── github-actions/                       # GitHub Actions approach
│   └── .github/workflows/deploy-semantic-view.yml
│
└── source/                               # Raw DDL/YAML exports (source of truth)
    ├── coles_retail_sv.sql
    └── coles_retail_sv.yaml
```

## Semantic Model

The demo uses **COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL**, which includes:

- **10 tables**: Sales, Stores, Products, Suppliers, Reviews, Review Sentiment, Store Performance, Inventory Alerts, Support Tickets, Time Dimension
- **13 relationships**: Linking sales to products/stores/time, reviews to products/stores, etc.
- **10 facts, 25 dimensions, 20+ metrics, 4 verified queries, AI instructions**

## Quick Start

### Option 1: DCM Projects

The DCM project is at the repository root (`manifest.yml` + `sources/`). It supports three environments via Jinja templating:

| Target | Database | Project Location |
|--------|----------|-----------------|
| dev | COLES_RETAIL_DB_DEV | COLES_RETAIL_DB.PROJECTS.COLES_RETAIL_SV_PROJECT |
| test | COLES_RETAIL_DB_TEST | COLES_RETAIL_DB_TEST.PROJECTS.COLES_RETAIL_SV_PROJECT |
| prod | COLES_RETAIL_DB_PROD | COLES_RETAIL_DB_PROD.PROJECTS.COLES_RETAIL_SV_PROJECT |

```bash
# Preview changes for an environment
snow dcm plan --target dev

# Deploy to dev
snow dcm deploy --target dev

# Deploy to production
snow dcm deploy --target prod
```

In **Snowsight Workspaces**: Create a workspace from this Git repository. The DCM project controls will appear since `manifest.yml` is at root.

### Option 2: Snowflake Git Repository

```sql
-- One-time setup (run git-repository/setup/create_git_repo.sql)

-- Deploy: fetch latest and execute all objects in dependency order
-- Run: git-repository/scripts/fetch_and_deploy.sql
ALTER GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO FETCH;
EXECUTE IMMEDIATE FROM @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/git-repository/scripts/fetch_and_deploy.sql;
```

### Option 3: GitHub Actions

```bash
# Edit the semantic view source
vim source/coles_retail_sv.sql

# Push to trigger deployment
git add . && git commit -m "Update semantic view" && git push
```

## Verification

```sql
SHOW SEMANTIC VIEWS LIKE 'COLES_RETAIL_SEMANTIC_MODEL' IN SCHEMA COLES_RETAIL_DB.AI_ANALYTICS;
DESCRIBE SEMANTIC VIEW COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL;
```

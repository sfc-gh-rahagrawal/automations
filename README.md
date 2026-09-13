# Semantic View DevOps Deployment Demo

Automated deployment of Snowflake Semantic Views using three different DevOps approaches, demonstrated with the **Coles Retail Semantic Model**.

## Overview

This repository contains working examples of three deployment approaches for Snowflake semantic views. Each approach is self-contained with its own README, setup instructions, and deployment scripts.

| Approach | Type | Multi-Env | CI/CD | Rollback | Best For |
|----------|------|-----------|-------|----------|----------|
| [DCM Projects](semantic-view/01-dcm-project/) | Snowflake-native IaC | Jinja templating | `snow dcm plan/deploy/test` | Redeploy previous version | Teams wanting declarative infrastructure |
| [Snowflake Git Repo](semantic-view/02-git-repository/) | Snowflake-native Git | Branches/tags | `EXECUTE IMMEDIATE FROM` | Checkout previous tag | No external CI tools needed |
| [GitHub Actions](semantic-view/03-github-actions/) | External CI/CD | Branch-based | GitHub Actions workflows | Git revert + re-trigger | Teams with existing GitHub workflows |

## Architecture

```
                    +-------------------+
                    |   GitHub Repo     |
                    | (Source of Truth) |
                    +--------+----------+
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
     +--------+----+  +-----+------+  +----+--------+
     | DCM Project |  | Snowflake  |  | GitHub      |
     |             |  | Git Repo   |  | Actions     |
     | DEFINE ...  |  | EXECUTE    |  | snow sql    |
     | snow dcm    |  | IMMEDIATE  |  | on push     |
     | deploy      |  | FROM @repo |  |             |
     +------+------+  +-----+------+  +------+------+
            |              |                |
            +--------------+----------------+
                           |
                           v
                  +--------+--------+
                  | Snowflake       |
                  | COLES_RETAIL_DB |
                  | .AI_ANALYTICS   |
                  | .COLES_RETAIL_  |
                  | SEMANTIC_MODEL  |
                  +-----------------+
```

## Semantic Model

The demo uses the **Coles Retail Semantic Model** (`COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL`), which includes:

- **10 tables**: Sales, Stores, Products, Suppliers, Reviews, Review Sentiment, Store Performance, Inventory Alerts, Support Tickets, Time Dimension
- **13 relationships**: Linking sales to products/stores/time, reviews to products/stores, etc.
- **10 facts**: Revenue, quantity, discount, profit, base price, foot traffic, etc.
- **25 dimensions**: Date, store, product, brand, category, sentiment, etc.
- **20+ metrics**: Revenue, units sold, gross margin %, ASP, conversion rate, NPS proxy, etc.
- **4 verified queries**: Monthly sales trends, dairy analysis, brand performance
- **AI instructions**: Custom SQL generation and question categorization rules

## Quick Start

### Option 1: DCM Projects

```bash
cd semantic-view/01-dcm-project

# Preview changes
snow dcm plan --target dev

# Deploy to dev
snow dcm deploy --target dev

# Deploy to production
snow dcm deploy --target prod
```

### Option 2: Snowflake Git Repository

```sql
-- One-time setup (creates the Git Repository object)
-- Run: semantic-view/02-git-repository/setup/create_git_repo.sql

-- Deploy (fetch + execute)
ALTER GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO FETCH;

EXECUTE IMMEDIATE FROM
  @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/deploy_semantic_view.sql;
```

### Option 3: GitHub Actions

```bash
# Edit the semantic view
vim semantic-view/source/coles_retail_sv.sql

# Push to trigger deployment
git add . && git commit -m "Update semantic view" && git push
```

## Repository Structure

```
automations/
├── README.md                              # This file
├── semantic-view/
│   ├── source/
│   │   ├── coles_retail_sv.sql            # DDL source of truth
│   │   └── coles_retail_sv.yaml           # YAML export
│   │
│   ├── 01-dcm-project/                    # DCM Projects approach
│   │   ├── README.md
│   │   ├── manifest.yml
│   │   ├── definitions/
│   │   │   ├── semantic_view.sql          # DEFINE with Jinja
│   │   │   └── grants.sql
│   │   └── configurations/
│   │       ├── dev.yml
│   │       └── prod.yml
│   │
│   ├── 02-git-repository/                 # Snowflake Git Repo approach
│   │   ├── README.md
│   │   ├── setup/
│   │   │   └── create_git_repo.sql
│   │   ├── deploy/
│   │   │   └── deploy_semantic_view.sql
│   │   └── scripts/
│   │       └── fetch_and_deploy.sql
│   │
│   └── 03-github-actions/                 # GitHub Actions approach
│       ├── README.md
│       └── .github/
│           └── workflows/
│               └── deploy-semantic-view.yml
```

## When to Use Which?

| Scenario | Recommended Approach |
|----------|---------------------|
| Snowflake-first team, want plan/deploy/test workflow | **DCM Projects** |
| Need deployment without any external tools | **Snowflake Git Repo** |
| Already using GitHub for CI/CD | **GitHub Actions** |
| Need environment promotion (dev -> staging -> prod) | **DCM Projects** (Jinja) or **GitHub Actions** (environments) |
| Want to schedule periodic deployments | **Snowflake Git Repo** (with Tasks) |
| Need PR-based review before deployment | **GitHub Actions** (PR triggers) |

## Verification

After deploying with any approach, verify with:

```sql
-- Check the semantic view exists
SHOW SEMANTIC VIEWS LIKE 'COLES_RETAIL_SEMANTIC_MODEL' IN SCHEMA COLES_RETAIL_DB.AI_ANALYTICS;

-- Inspect the structure
DESCRIBE SEMANTIC VIEW COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL;

-- Test a query
SELECT * FROM SEMANTIC_VIEW(
  COLES_RETAIL_DB.AI_ANALYTICS.COLES_RETAIL_SEMANTIC_MODEL
  METRICS SALES.REVENUE
  DIMENSIONS STORES.LOC_NM, TIME_DIM.YEAR_MONTH
) LIMIT 10;
```

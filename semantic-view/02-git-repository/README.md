# Option 2: Snowflake Git Repository

Deploy the Coles Retail Semantic View using Snowflake's native Git integration and `EXECUTE IMMEDIATE FROM`.

## What is Snowflake Git Repository?

Snowflake can connect directly to a remote Git repository, creating a `GIT REPOSITORY` object that acts as a read-only clone. You can then execute SQL files from the repo using `EXECUTE IMMEDIATE FROM`.

## Key Features

- **Snowflake-native**: No external CI/CD tools needed
- **Direct GitHub integration**: Uses Snowflake secrets and API integrations
- **Version control**: Deploy from specific branches or tags
- **Schedulable**: Can be automated with Snowflake Tasks

## Files

```
02-git-repository/
├── setup/
│   └── create_git_repo.sql       # One-time: CREATE GIT REPOSITORY
├── deploy/
│   └── deploy_semantic_view.sql  # CREATE OR REPLACE SEMANTIC VIEW
└── scripts/
    └── fetch_and_deploy.sql      # FETCH + EXECUTE IMMEDIATE orchestration
```

## Prerequisites

- A GitHub Personal Access Token stored as a Snowflake secret (`DB_GOVERNANCE.REPO.GITHUB_SECRET_TOKEN`)
- An API integration (`GITHUB_API_INTEGRATION`) allowing access to `https://github.com/sfc-gh-rahagrawal`

## Setup (One-Time)

Run the setup script in Snowflake:

```sql
-- Creates the GIT REPOSITORY object
EXECUTE IMMEDIATE FROM 'setup/create_git_repo.sql';

-- Or run directly:
CREATE OR REPLACE GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO
  API_INTEGRATION = GITHUB_API_INTEGRATION
  GIT_CREDENTIALS = DB_GOVERNANCE.REPO.GITHUB_SECRET_TOKEN
  ORIGIN = 'https://github.com/sfc-gh-rahagrawal/automations.git';
```

## Usage

### Deploy (fetch latest + execute)

```sql
-- Fetch latest from GitHub
ALTER GIT REPOSITORY COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO FETCH;

-- Deploy semantic view
EXECUTE IMMEDIATE FROM
  @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/deploy/deploy_semantic_view.sql;
```

### Or use the orchestration script

```sql
-- One-step fetch + deploy + verify
EXECUTE IMMEDIATE FROM
  @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/scripts/fetch_and_deploy.sql;
```

### Schedule with a Task

```sql
CREATE OR REPLACE TASK COLES_RETAIL_DB.AI_ANALYTICS.DEPLOY_SEMANTIC_VIEW_TASK
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = 'USING CRON 0 6 * * * UTC'
AS
  EXECUTE IMMEDIATE FROM
    @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/branches/main/semantic-view/02-git-repository/scripts/fetch_and_deploy.sql;
```

### Deploy from a specific tag

```sql
-- Deploy a tagged release
EXECUTE IMMEDIATE FROM
  @COLES_RETAIL_DB.AI_ANALYTICS.AUTOMATIONS_REPO/tags/v1.0/semantic-view/02-git-repository/deploy/deploy_semantic_view.sql;
```

## How It Works

```
Developer pushes changes to GitHub
    |
    v
ALTER GIT REPOSITORY ... FETCH     -- Snowflake syncs the clone
    |
    v
EXECUTE IMMEDIATE FROM @repo/...   -- Snowflake runs the SQL file
    |
    v
Semantic view is created/updated
```

## Rollback

To rollback, deploy from a previous tag:

```sql
ALTER GIT REPOSITORY AUTOMATIONS_REPO FETCH;
EXECUTE IMMEDIATE FROM @AUTOMATIONS_REPO/tags/v0.9/semantic-view/02-git-repository/deploy/deploy_semantic_view.sql;
```

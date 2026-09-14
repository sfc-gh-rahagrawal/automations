# Option 3: GitHub Actions CI/CD

Deploy the Coles Retail Semantic View automatically on every push to `main` using GitHub Actions.

## What is this?

A GitHub Actions workflow that runs on every push to `main` (when files in `semantic-view/source/` change). It installs the Snowflake CLI, connects to your Snowflake account, and executes the semantic view DDL.

## Key Features

- **Automatic deployment**: Push to `main` triggers deployment
- **PR validation**: Pull requests run a validation check
- **Manual trigger**: Can also be triggered manually via `workflow_dispatch`
- **Verification step**: Confirms the semantic view was created successfully

## Files

```
03-github-actions/
├── .github/
│   └── workflows/
│       └── deploy-semantic-view.yml   # GitHub Actions workflow
└── README.md
```

## Prerequisites

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

| Secret | Value |
|--------|-------|
| `SNOWFLAKE_ACCOUNT` | Your Snowflake account identifier (e.g., `SFPSCOGS-ragrawal_azure_bcdemo`) |
| `SNOWFLAKE_USER` | Snowflake username (e.g., `RAHAGRAWAL`) |
| `SNOWFLAKE_PASSWORD` | Snowflake password |

## Setup

1. Copy `.github/workflows/deploy-semantic-view.yml` to the root of your repo
2. Add the required secrets to GitHub
3. Push changes to `semantic-view/source/coles_retail_sv.sql`
4. The workflow triggers automatically

## Workflow Triggers

| Event | Action |
|-------|--------|
| Push to `main` (source files changed) | Deploy semantic view |
| Pull request to `main` | Validate connection |
| Manual dispatch | Deploy semantic view |

## Usage

### Automatic (on push)

```bash
# Edit the semantic view DDL
vim semantic-view/source/coles_retail_sv.sql

# Commit and push
git add .
git commit -m "Update semantic view metrics"
git push origin main

# GitHub Actions automatically deploys
```

### Manual trigger

1. Go to **Actions** tab in GitHub
2. Select **Deploy Semantic View** workflow
3. Click **Run workflow**

## How It Works

```
Developer pushes to main
    |
    v
GitHub Actions triggers
    |
    v
Install Snowflake CLI
    |
    v
snow sql -f semantic-view/source/coles_retail_sv.sql
    |
    v
Verify: SHOW SEMANTIC VIEWS
    |
    v
Deployment confirmed
```

## Extending the Workflow

### Add environment promotion

```yaml
deploy-prod:
  needs: deploy-staging
  environment: production
  steps:
    - name: Deploy to Production
      run: snow sql -f semantic-view/source/coles_retail_sv.sql
      env:
        SNOWFLAKE_DATABASE: COLES_RETAIL_DB  # prod database
```

### Add Slack notifications

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: "Semantic view deployment ${{ job.status }}"
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

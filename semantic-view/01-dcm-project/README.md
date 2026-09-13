# Option 1: DCM Projects

Deploy the Coles Retail Semantic View using Snowflake DCM (Database Change Management) Projects.

## What is DCM?

DCM Projects provide declarative infrastructure-as-code for Snowflake objects. You write `DEFINE` statements (similar to `CREATE OR ALTER`), and DCM handles planning, deploying, and testing changes.

## Key Features

- **Jinja Templating**: `{{env_suffix}}` lets you deploy to `COLES_RETAIL_DB_DEV` or `COLES_RETAIL_DB` (prod)
- **Plan Before Deploy**: Preview changes before applying them
- **Test After Deploy**: Run data quality expectations post-deployment
- **Declarative Grants**: RBAC managed alongside object definitions

## Files

```
01-dcm-project/
├── manifest.yml                  # Project metadata
├── definitions/
│   ├── semantic_view.sql         # DEFINE SEMANTIC VIEW with Jinja
│   └── grants.sql               # RBAC grants
└── configurations/
    ├── dev.yml                   # env_suffix = "_DEV"
    └── prod.yml                  # env_suffix = ""
```

## Prerequisites

```bash
# Install Snowflake CLI
pip install snowflake-cli

# Verify connection
snow connection test -c <your_connection>
```

## Usage

### Plan (preview changes without deploying)

```bash
snow dcm plan --target dev
```

### Deploy to Dev

```bash
snow dcm deploy --target dev
```

### Deploy to Production

```bash
snow dcm deploy --target prod
```

### Test Data Quality

```bash
snow dcm test --target dev
```

## How It Works

1. `DEFINE SEMANTIC VIEW` runs as `CREATE OR ALTER SEMANTIC VIEW` internally
2. Jinja renders `{{env_suffix}}` based on the target configuration
3. DCM reconciles the full semantic view definition: tables, relationships, facts, dimensions, metrics, AI instructions, and verified queries
4. Grants are applied after the semantic view is created

## Multi-Environment Flow

```
Developer edits definitions/semantic_view.sql
    |
    v
snow dcm plan --target dev      # Preview changes
    |
    v
snow dcm deploy --target dev    # Deploy to COLES_RETAIL_DB_DEV
    |
    v
snow dcm test --target dev      # Validate data quality
    |
    v
snow dcm deploy --target prod   # Promote to COLES_RETAIL_DB
```

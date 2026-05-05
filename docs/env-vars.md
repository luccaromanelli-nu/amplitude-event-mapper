# Environment variables

All env vars are optional with sensible defaults. Set them in `.env` (copy from `.env.example`). The plugin reads them via the shell when the `--plugin-dir` flag launches Claude.

## Variables

| Variable | Default | Required for | Purpose |
|----------|---------|--------------|---------|
| `NU_BU` | `cc-financing` | Databricks live mode | Mantiqueira BU group; gates Databricks workspace + cluster permissions |
| `NU_COUNTRY` | `BR` | All | Drives Databricks table names (`magnitude.<country>.amplitude_events`), naming defaults |
| `NU_DATABRICKS_HOST` | unset | Databricks live mode | Databricks workspace URL |
| `NU_DATABRICKS_TOKEN` | unset | Databricks live mode | Personal access token (read-only role) |
| `NU_DATABRICKS_WAREHOUSE_ID` | unset | Databricks live mode | SQL warehouse to route the query |
| `NU_DATABRICKS_WORKSPACE` | `credit-strategy` | Databricks live mode | Workspace tag (informational) |
| `NU_DEFAULT_PROVIDER` | `finn` | Proposer | Default value for the `provider` property |
| `NU_DEFAULT_PACKAGE` | `catalyst_entrypoint` | Proposer | Default value for the `package` property |
| `NU_CATALOG_PATH` | `catalog/events.md` | Catalog suggester | Path to seed catalog |
| `FIGMA_TOKEN` | unset | Figma live mode | Figma personal access token (read-only) |

## Per-BU overrides

`NU_BU` is the primary access gate. Different BUs use different Databricks workspaces and Mantiqueira groups. Setting `NU_BU` correctly is the difference between a working query and a permission denied error.

If you are outside CC Financing:

```bash
NU_BU=<your-bu>                         # check Mantiqueira for the exact group name
NU_DEFAULT_PROVIDER=<your-bff-or-bdc>
NU_DEFAULT_PACKAGE=<your-bdc-package>
```

## Demo mode

When invoking with `--demo`, every env var becomes optional. The fixture readers do not consult them.

## Auth not handled here

Env vars handle config. Auth is per-MCP — see [`auth.md`](auth.md):

- Figma — `FIGMA_TOKEN`
- Miro — OAuth flow on first use
- Atlassian — OAuth flow on first use (handled by Claude Code's built-in MCP)
- Databricks — `NU_DATABRICKS_HOST` + `NU_DATABRICKS_TOKEN`

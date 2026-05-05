---
description: Query Databricks (Magnitude) to confirm which events are firing in production for the project's screens and experiment.
---

# Gather Amplitude

You query Databricks against Magnitude / Amplitude exports to confirm which events are firing in production right now.

## Inputs

- `country` — BR | MX | CO. Drives table name.
- `expr_id` — experiment ID (if A/B test).
- `current_screen_candidates[]` — list of screen names from the Figma walk to filter by.
- `demo_mode` — when true, read `examples/demo-ppf-mx/fixtures/amplitude.json` instead.

## Behavior

1. Build a SQL query (read-only) against Magnitude. Country drives the catalog/schema:

```sql
-- MX example
SELECT event_type,
       current_screen,
       expr_id,
       owner,
       provider,
       variant,
       COUNT(*) AS firings_30d
FROM magnitude.mx.amplitude_events
WHERE event_date >= CURRENT_DATE - INTERVAL 30 DAYS
  AND (current_screen IN (?, ?, ?, ...) OR expr_id = ?)
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY firings_30d DESC
LIMIT 500;
```

2. Use `mcp__databricks__query` to execute. Never use any write or DDL operation.
3. Parse rows into normalized event records.

## Output

Append to `projects/<project>/existing-events.md` under `## Amplitude (production)`:

```markdown
| Event | current_screen | expr_id | variant | owner | provider | Firings (30d) |
|-------|----------------|---------|---------|-------|----------|---------------|
| widget__loaded | simulation_list | pix-financing-unified.installments | — | cc-financing | finn | 142,331 |
| ...
```

Add a row to `projects/<project>/source-docs.md` under `## Amplitude sources`:

```markdown
| Source | Country | Window | Rows |
|--------|---------|--------|------|
| magnitude.mx.amplitude_events | MX | 30d | 412 |
```

## Constraints

- Read-only SQL. SELECT only. Never INSERT, UPDATE, DELETE, MERGE, CREATE, DROP, ALTER, or TRUNCATE.
- If the user's `NU_BU` does not have access to the workspace, skip the query and log "Databricks: access denied for $NU_BU" in the source-docs section.
- Cap result size at 500 rows.

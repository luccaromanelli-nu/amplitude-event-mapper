---
description: Run only the gather phase — refresh inputs from Figma, Miro, Confluence, and Databricks without re-running cross-check or proposal.
---

# /amplitude-event-mapper:gather

Run only the gather phase. Use this when you want to refresh input data without re-running analysis.

## Usage

```
/amplitude-event-mapper:gather <project-name>
/amplitude-event-mapper:gather --demo
```

Project arg: `$ARGUMENTS`

## Behavior

1. Read `projects/$ARGUMENTS/input.yaml`.
2. Spawn the four gather agents in parallel:
   - figma-walker
   - miro-event-fetcher
   - confluence-event-fetcher
   - databricks-amplitude-prober
3. Aggregate output into `projects/<project>/existing-events.md` and `projects/<project>/source-docs.md`.

## Output

- `projects/<project>/source-docs.md`
- `projects/<project>/existing-events.md`

Does not run cross-check, proposer, or formatter.

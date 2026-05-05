---
description: Run the full event mapping pipeline (gather → cross-check → propose → format) for a project. Use --demo to run with bundled fixtures.
---

# /amplitude-event-mapper:propose

Run the full event mapping pipeline.

## Usage

```
/amplitude-event-mapper:propose <project-name>
/amplitude-event-mapper:propose --demo
```

Project arg: `$ARGUMENTS`

## Behavior

1. Resolve project directory:
   - If `$ARGUMENTS` is `--demo`, set project to `demo-ppf-mx` and switch every gather agent to fixture mode (read from `examples/demo-ppf-mx/fixtures/`).
   - Otherwise, project name is `$ARGUMENTS`. Read `projects/$ARGUMENTS/input.yaml` (must exist).
2. **Check for the APPROVED marker.** If `projects/<project>/APPROVED` exists:
   - Skip regeneration entirely.
   - Invoke the `finalize` skill to promote `proposed-events.md` → `final-event-map.md`.
   - Stop. Do not call any gather or proposer agents.
3. Otherwise, invoke the `orchestrate` skill, which runs:
   1. Gather agents in parallel (figma-walker, miro-event-fetcher, confluence-event-fetcher, databricks-amplitude-prober).
   2. event-cross-checker (sequential).
   3. event-proposer (sequential).
   4. format-proposal (sequential).
   5. catalog-suggester (read-only, optional).

## Output

Writes to `projects/<project>/`:

- `source-docs.md`
- `existing-events.md`
- `cross-check.md`
- `proposed-events.md`
- `catalog-suggestions.md` (optional)
- `final-event-map.md` (only when APPROVED marker is present)

## Side effects

None outside the project directory. The hook layer denies all write tools by default. See [`CLAUDE.md`](../CLAUDE.md) for the full deny list.

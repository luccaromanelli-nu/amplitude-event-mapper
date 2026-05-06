---
description: Run the full event mapping pipeline. Spawns gather agents in parallel, then cross-checker, proposer, formatter, and catalog suggester sequentially. Use when the user runs /amplitude-event-mapper:propose.
---

# Orchestrate

You are the orchestrator for the amplitude-event-mapper plugin. Your job is to run the full pipeline against a project and write all output files to `projects/<project>/`.

## Inputs

- `project_name` — the project slug, or `demo-ppf-mx` if `--demo` flag was passed.
- `demo_mode` — boolean. When true, every gather agent reads from `examples/demo-ppf-mx/fixtures/` instead of live MCP sources.

## Pipeline

### Step 0 — APPROVED check

If `projects/<project>/APPROVED` exists, do NOT regenerate. Invoke the `finalize` skill and stop.

### Step 1 — Read input

Read `projects/<project>/input.yaml`.

If the file does not exist, stop with:

```
projects/<project>/input.yaml not found.

Run /amplitude-event-mapper:create-project <project> to scaffold it interactively,
or copy templates/input-template.yaml into projects/<project>/input.yaml and edit by hand.
```

Do NOT call any gather agents in this case.

Validate the input has at minimum:

- `project_name`
- `scope`
- `country` (BR | MX | CO)
- `sources.figma` (at least one URL or fixture path)

If `ab_test: true`, validate `cells` includes `control` plus at least one variant, and `expr_id` is set.

### Step 2 — Gather (parallel)

Spawn the four gather agents in a SINGLE message with parallel tool calls:

- `figma-walker` — input: `sources.figma`, output: screen inventory + interaction list
- `miro-event-fetcher` — input: `sources.miro`, output: documented events
- `confluence-event-fetcher` — input: `sources.confluence`, output: RFC + tech-assessment events
- `databricks-amplitude-prober` — input: `country`, `expr_id`, `current_screen` candidates from Figma, output: events firing in production

Each agent writes its own section into `projects/<project>/existing-events.md` and contributes a row to `projects/<project>/source-docs.md`.

### Step 3 — Cross-check (sequential)

Invoke `event-cross-checker` agent. Reads:

- `projects/<project>/existing-events.md`
- `projects/<project>/source-docs.md` (Figma screen inventory)

Writes `projects/<project>/cross-check.md` with:

- Documented but not firing → stale or broken
- Firing but not documented → undocumented
- Property mismatches across sources
- Figma screens not covered by any event

### Step 4 — Propose (sequential)

Invoke `event-proposer` agent. Reads existing-events.md, cross-check.md, input.yaml. Loads the `decision-tree` skill. Produces a structured event proposal:

- One event per screen / button / interaction
- Comparison table when cells share an event
- `[NEW]` tag on every property value not yet in production
- `[CONFIRM]` tag on every value needing engineer validation
- `[NEEDS-HUMAN]` tag on edge cases requiring manual decision
- Per-event rationale (one line, business question)
- Per-cell coverage (control + variants) for A/B tests

### Step 5 — Format (sequential)

Invoke the `format-proposal` skill. Reads the proposer output and renders to `projects/<project>/proposed-events.md` using `templates/proposal-template.md`.

### Step 6 — Catalog suggest (read-only)

Invoke `catalog-suggester` agent. Reads proposed-events.md and `catalog/events.md`. Writes `projects/<project>/catalog-suggestions.md` listing canonical events worth promoting (humans review and decide separately).

## Output

When done, summarize:

```
[orchestrate] done.
  projects/<project>/source-docs.md          (N entries)
  projects/<project>/existing-events.md      (N events)
  projects/<project>/cross-check.md          (N gaps)
  projects/<project>/proposed-events.md      (N proposed)
  projects/<project>/catalog-suggestions.md  (N candidates)

Next: review proposed-events.md, resolve [CONFIRM] items, then `touch projects/<project>/APPROVED` and rerun /amplitude-event-mapper:propose <project>.
```

## Constraints

- All file writes must be inside `projects/<project>/`. Never modify `catalog/`, `templates/`, `examples/`, or any source code.
- Never call write tools (Slack send, Atlassian create, Bash, etc.). The hook layer denies them but you should not attempt them.
- Never auto-create the `APPROVED` marker. Only humans create it.

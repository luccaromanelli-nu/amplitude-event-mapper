# Workflow

## Pipeline overview

```
            ┌─ figma-walker ──────────┐
            ├─ miro-event-fetcher ────┤
   gather   ├─ confluence-fetcher ────┤  parallel
            └─ databricks-prober ─────┘
                       ↓
              event-cross-checker        sequential
                       ↓
              event-proposer             sequential (loads decision-tree skill)
                       ↓
              format-proposal            sequential
                       ↓
              catalog-suggester          read-only
                       ↓
                human review             pause
                       ↓
              format-proposal --finalize on APPROVED marker
```

## Phases

### 1. Gather (parallel)

Four agents run at the same time, each writing its section of `existing-events.md` and a row of `source-docs.md`.

| Agent | Source | What it produces |
|-------|--------|------------------|
| figma-walker | Figma file(s) | screen inventory: every screen, button, row, widget, with cell + interaction type |
| miro-event-fetcher | Miro board(s) | documented events from sticky notes / cards |
| confluence-event-fetcher | Confluence pages | documented events from RFCs and tech assessments |
| databricks-amplitude-prober | Databricks (Magnitude) | events firing in production with property values + firing counts |

Demo mode swaps every MCP call for a fixture file read.

### 2. Cross-check (sequential)

`event-cross-checker` builds the gap matrix:

- **Stale or broken** — documented but not firing
- **Undocumented** — firing but not documented
- **Property mismatches** — same event, different property values across sources
- **Uncovered Figma nodes** — Figma nodes with no matching event
- **A/B coverage gap** — events missing per-cell coverage

Output: `cross-check.md`.

### 3. Propose (sequential)

`event-proposer` loads the `decision-tree` skill and applies it to every Figma node:

1. Pick the right NuDS# event type
2. Assign required properties
3. Reuse existing event with new property values when possible
4. Tag new values `[NEW]`, uncertain values `[CONFIRM]`, edge cases `[NEEDS-HUMAN]`
5. For A/B tests, define every event for every cell + add `variant` property
6. Apply delta-only rule: emit only what changes vs control

Hand-off: `.tmp/proposer-output.md`.

### 4. Format (sequential)

`format-proposal` skill renders the structured proposer output as `proposed-events.md` using `templates/proposal-template.md`. Comparison tables for shared events. Open-questions checklist at the bottom.

### 5. Catalog suggest (read-only)

`catalog-suggester` compares the proposal against `catalog/events.md` and writes catalog promotion candidates to `catalog-suggestions.md`. Never modifies the catalog.

### 6. Human review

The plugin pauses. The engineer reads `proposed-events.md`, ticks off `[CONFIRM]` and `[NEEDS-HUMAN]` items, and either:

- Edits `existing-events.md` or `cross-check.md` and re-runs `/propose-only` to regenerate
- Approves: `touch projects/<project>/APPROVED`

### 7. Finalize (on APPROVED marker)

Re-running `/propose` (or running `/finalize` directly) detects the marker and:

- Strips `[CONFIRM]` tags
- Preserves `[NEW]` tags
- Strips the open-questions checklist and "Out of scope" sections
- Writes `final-event-map.md`

## Re-run patterns

| Situation | Command |
|-----------|---------|
| Fresh run | `/propose <project>` |
| Engineer corrected gather data; want fresh proposal | `/propose-only <project>` |
| Want a fresh gap matrix only | `/cross-check <project>` |
| Refresh inputs without re-proposing | `/gather <project>` |
| Approved | `touch APPROVED && /finalize <project>` |

## Determinism

The pipeline is not bit-deterministic (LLM-based judgment is involved), but it is heavily templated. The decision tree, templates, and tagging conventions constrain output shape. The smoke test in `bin/smoke-test.sh` provides a regression baseline against the bundled demo project — if it diverges meaningfully, investigate.

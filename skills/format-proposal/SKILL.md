---
description: Render the event-proposer output into proposed-events.md using the proposal template. Applies comparison-table format for A/B cells.
---

# Format proposal

You take the event-proposer's structured output and render it as the final `proposed-events.md`.

## Inputs

- The event-proposer's structured proposal (in-memory or as `projects/<project>/.tmp/proposer-output.md`)
- `projects/<project>/input.yaml` (for project metadata: name, scope, cells, expr_id)
- `templates/proposal-template.md` (the template to fill)

## Behavior

1. Load the template.
2. Substitute project metadata.
3. For each proposed event:
   - If A/B test and the event applies to multiple cells with shared property names, render a comparison table (cells as columns, properties as rows).
   - Otherwise, render a single event block.
4. Tag every property value:
   - `[NEW]` if it does not exist in production
   - `[CONFIRM]` if it exists but needs engineer validation
   - `[NEEDS-HUMAN]` if it is an edge case requiring manual decision
5. Add a per-event one-line rationale (the business question it answers).
6. Collect all `[CONFIRM]` and `[NEEDS-HUMAN]` items into a single numbered open-questions checklist at the bottom.
7. Add an "Out of scope" section listing what was intentionally not covered.

## Output

Write `projects/<project>/proposed-events.md`.

## Constraints

- Pure rendering. No MCP calls.
- The template already exists at `templates/proposal-template.md`. Never re-generate the template.
- The proposed events must be in the same order as the Figma walk (top-down, screen-by-screen) so reviewers can scan against the design.

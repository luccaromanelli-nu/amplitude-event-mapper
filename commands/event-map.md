---
description: Generate an HTML Amplitude event-mapping proposal from a Figma file, a PRD, and the existing analytics in code (via Glean).
argument-hint: "[figma_url] [prd_url] [metrics_url]"
---

Run the `event-map` skill to produce a self-contained HTML event proposal.

Inputs (all optional on the command line — the skill prompts for any missing required value):

- `$1` — Figma URL (file or specific frame)
- `$2` — PRD URL (Google Doc, Confluence page, web URL, or local path)
- `$3` — Metrics deck URL (optional analysis context)

The skill will:

1. Fetch the Figma frame tree and PRD text in parallel.
2. Use Glean code search to locate the existing flow in code (default: `nubank/finn`) and extract `expr_id`, `:analytics-context`, and `:button-analytics-props`.
3. Pause for human confirmation at four gates: flow location, instrumentation extraction, cell reconciliation, and measurement intent.
4. Apply `docs/decision-tree.md` to map every Figma delta onto an existing event with new property values (never new event types).
5. Write `projects/<slug>/proposal.html`.

Hard rule: never invent a new Amplitude event type. Reuse the existing taxonomy only.

Invoke the skill: **event-map** with arguments `$1`, `$2`, `$3`.

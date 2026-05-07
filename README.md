# amplitude-event-mapper

A single-purpose Claude Code plugin that produces an HTML Amplitude event-mapping proposal from three inputs:

- a **Figma** file (the test design)
- a **PRD** (Google Doc, Confluence page, URL, or local file)
- the **existing analytics in code**, looked up via Glean code search

The output is a self-contained HTML file that mirrors the PPF Awareness reference deliverable: hero, project meta, A/B cell table, user-flow map, per-screen sections with side-by-side cell screenshots and per-cell property tables, plus an open-questions checklist for engineers.

## Hard rule

The plugin **never invents new event types**. Tests must reuse the existing taxonomy (`screen__viewed`, `button__clicked`, `widget__clicked`, `deeplink_clicked`, …) and propose only new property values on top.

## Requirements

| Dependency | Notes |
|------------|-------|
| Figma MCP | Mandatory. Configured in `.mcp.json`. Set `FIGMA_TOKEN`. |
| Glean MCP | Mandatory. User-level config. Used to search code for `expr_id`, `:analytics-context`, `:button-analytics-props`, direct event calls. |
| Google Workspace MCP | Optional. Used when the PRD URL is a Google Doc. Falls back to `WebFetch`. |
| Atlassian MCP | Optional. Used when the PRD URL is a Confluence page. Falls back to `WebFetch`. |

## Usage

```
/event-map [figma_url] [prd_url] [metrics_url]
```

All three args are optional — the skill will prompt for any missing required input.

`metrics_url` is optional context (a slide deck or doc with the analyses the team wants to run). When supplied, the skill uses it to prioritize which properties to propose.

## What the skill does

1. Fetches the Figma frame tree and exports a PNG per cell frame.
2. Fetches the PRD text from whichever source the URL points at.
3. Asks Glean to find the matching flow in code (defaults to `nubank/finn` for CC Financing).
4. Pauses for human confirmation at four gates:
   1. correct flow file(s) identified?
   2. extracted `expr_id` + analytics context look right?
   3. cell list reconciles between Figma and PRD?
   4. measurement intent is clear?
5. Applies the decision tree in `docs/decision-tree.md` to map every Figma delta onto an existing event with new property values.
6. Writes `projects/<slug>/proposal.html`.

## Output

A single self-contained HTML file. Each event block carries:

- the existing event name (never invented)
- a `Reuse — found in <repo>:<file>:<line>` citation
- per-cell property comparison table with `[NEW]` / `[CONFIRM]` tags
- a one-line rationale stating which business question the event answers

Every `[CONFIRM]` is collected into a numbered open-questions checklist at the bottom of the page.

## Side effects

None. The skill writes only `projects/<slug>/proposal.html` (and optionally cell PNGs under `projects/<slug>/assets/`). It never posts to Slack, comments on Jira, or edits Confluence.

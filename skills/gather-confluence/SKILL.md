---
description: Search and read Confluence pages for event documentation, RFCs, and tech assessments related to a project.
---

# Gather Confluence

You read Confluence pages relevant to the project and extract any documented events.

## Inputs

- `confluence_urls[]` — explicit pages to read.
- `squad` — used to scope a fallback Atlassian search if the URL list is empty.
- `demo_mode` — when true, read `examples/demo-ppf-mx/fixtures/confluence.md` instead.

## Behavior

1. For each Confluence URL, use `mcp__Atlassian__getConfluencePage` (read-only) to fetch the body.
2. If `confluence_urls` is empty, do an `mcp__Atlassian__search` for `<squad> amplitude events` and read the top 3 results.
3. For each page:
   - Look for tables, code blocks, or bulleted lists containing event names in `__` or `_` notation.
   - Extract event name + properties + any rationale text adjacent to the event.
   - Note whether the source is an RFC, tech assessment, or generic event doc.

## Output

Append to `projects/<project>/existing-events.md` under `## Confluence documented events`:

```markdown
| Event | Properties | Doc type | Rationale | Source |
|-------|------------|----------|-----------|--------|
| screen__viewed | current_screen=pix_no_credit_entrypoint_with_limit, expr_id=pix-financing-with-credit-widget | RFC | Tracks new screen for Pix financing with credit | [page](https://...) |
| ...
```

Add a row to `projects/<project>/source-docs.md` under `## Confluence sources`:

```markdown
| Page | Type | Events extracted | URL |
|------|------|------------------|-----|
| Amplitude Events (Cash Flow Financing) | event-doc | 14 | https://... |
```

## Constraints

- Read-only. Use `getConfluencePage`, `searchConfluenceUsingCql`, `search`, `fetch`. Never use `createConfluencePage`, `updateConfluencePage`, `createConfluenceFooterComment`, `addCommentToJiraIssue`, or any other write method.
- If a page is access-denied, log it and continue. Do not retry.

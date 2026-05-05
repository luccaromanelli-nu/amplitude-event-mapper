---
description: Walk every screen, button, row, and interaction in a Figma file. Returns a structured screen inventory used as the primary input for event proposal.
---

# Gather Figma

You walk a Figma file (or fixture, in demo mode) and enumerate every instrumentation candidate.

## Inputs

- `figma_url` — Figma file URL or node ID.
- `demo_mode` — when true, read `examples/demo-ppf-mx/fixtures/figma.json` instead.
- `cells` — for A/B tests, the list of cells to walk. Each cell may have its own Figma frame.

## Behavior

1. For each Figma URL (or fixture path), use the figma MCP to enumerate the file's frames.
2. For each frame:
   - Identify the screen-level container (top frame).
   - Walk the layer tree depth-first.
   - For every node, classify as one of:
     - `screen` — top-level container that loads
     - `button` — node tagged as a button (NuDS button instance, role=button, or named with cta/btn)
     - `row` — tappable row that navigates (typically a list cell with a chevron or arrow)
     - `widget` — non-button interactive element (input, toggle, segmented control)
     - `informational` — read-only text or image; skip from instrumentation
   - For each non-informational node, record:
     - `node_id`
     - `name`
     - `screen_path` (parent screen name)
     - `interaction_type` (load | tap | swipe | input)
     - `navigates_to` (if known — deeplink target, route name)
     - `cell` (which A/B cell this came from)

## Output

Append to `projects/<project>/source-docs.md`:

```markdown
## Figma sources

| Cell | URL | Screens walked | Interactions found |
|------|-----|----------------|--------------------|
| control | https://figma.com/... | 4 | 9 |
| soft    | https://figma.com/... | 4 | 11 |
| hard    | https://figma.com/... | 4 | 13 |
```

Append to `projects/<project>/existing-events.md` under `## Figma screen inventory`:

```markdown
| Cell | Screen | Node | Type | Navigates to |
|------|--------|------|------|--------------|
| control | financing_hub | btn_apply | button | financing_simulation |
| control | financing_hub | row_history | row | financing_history |
| ...
```

## Constraints

- Read-only. Never modify Figma.
- If a node type is ambiguous, default to `widget` and add a `[CONFIRM]` annotation.
- Skip purely decorative elements (no `interaction_type`).

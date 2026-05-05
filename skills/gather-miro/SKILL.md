---
description: Extract documented events from the squad's Miro event reference board. Normalizes event cards to a uniform schema.
---

# Gather Miro

You read Miro boards and extract documented Amplitude events.

## Inputs

- `miro_board_urls[]` — list of Miro board URLs.
- `demo_mode` — when true, read `examples/demo-ppf-mx/fixtures/miro.json` instead.

## Behavior

1. For each Miro URL, use the miro MCP to list items on the board.
2. Filter to items that look like event cards:
   - Sticky notes or text blocks containing an event name in `__` or `_` notation (e.g. `widget__loaded`, `screen__viewed`)
   - Cards with property lists (key: value pairs) attached or linked
3. For each detected event, extract:
   - `event_name`
   - `properties` (key/value pairs as documented)
   - `screen` or `flow` context (parent frame, group title)
   - `source_url` (deep link to the Miro card)
4. Normalize property names to lowercase snake_case.

## Output

Append to `projects/<project>/existing-events.md` under `## Miro documented events`:

```markdown
| Event | Properties | Screen / flow | Source |
|-------|------------|---------------|--------|
| widget__loaded | current_screen=simulation_list, expr_id=pix-financing-unified.installments | financing_hub | [card](miro://...) |
| ...
```

Add a row to `projects/<project>/source-docs.md` under `## Miro sources`:

```markdown
| Board | Cards extracted | URL |
|-------|------------------|-----|
| Pix-financing Analytics Events | 11 | https://miro.com/... |
```

## Constraints

- Read-only. Do not modify Miro boards.
- If a card looks like an event but the parse is ambiguous, include it with a `[CONFIRM]` flag.
- Skip non-event content (general notes, legends, instructions).

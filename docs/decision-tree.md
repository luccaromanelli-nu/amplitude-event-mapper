# Decision tree

Authoritative rules consulted by the `event-map` skill on every Figma node.

## Rule 0 — Never invent new event types (HARD)

Reuse only the existing taxonomy. Tests must work within the current event types:

| Figma node | Default event |
|------------|---------------|
| Top-level screen container loads | `screen__viewed` (native) or `widget__loaded` (BDC widget) |
| CTA button | `button__clicked` or `widget__clicked` |
| Toggle / segmented / input widget | `widget__clicked` |
| Tappable row that navigates via deeplink | `deeplink_clicked` (NOT `widget__clicked`) |

If no existing event type fits, tag `[NEEDS-HUMAN]` and stop on that node. Do not propose a new event type.

## Rule 1 — Confirm the existing flow in code first

Before proposing anything, locate the matching flow in code via Glean and extract:

- the `expr_id` literal
- `:analytics-context` map keys + values (flow-level base properties)
- `:button-analytics-props` and direct event calls (interaction-level)

Record `repo:path:line` for every value. Pause at the confirm gate before continuing.

## Rule 2 — Same screen, different flow

The same button can appear in multiple flows. Use the SAME event, different property values:

- `current_screen` — different parent screen
- `expr_id` — different experiment
- `entrypoint_type` — BDC vs native vs deeplink

## Rule 3 — A/B test cells (CRITICAL)

When the change is an A/B test:

- Every event MUST be defined for every cell, including `control`.
- Add a `variant` (a.k.a. `experiment_group`) property with value = cell name.
- Without `variant` on every event, you cannot compare cells in Amplitude.
- Render shared-shape events as comparison tables (cells = columns).

## Rule 4 — Reuse properties before adding new

Before proposing a new property:

1. Check the analytics-context extracted from code.
2. Check existing events that already carry equivalent meaning.
3. Examples:
   - `financing_hub_options_group` differentiates Financing Hub variants — reuse with a new value.
   - `entrypoint_type` differentiates BDC vs native — do not invent `is_bdc`.

## Rule 5 — Delta-only documentation

Document ONLY what changes vs control. Do NOT list every existing event in every cell. Engineers need the diff, not the full state.

## Rule 6 — Right event type for navigation

Tappable row navigates to a new flow via deeplink → `deeplink_clicked` with a `tag` property identifying the option.

`deeplink_clicked` captures full navigation intent; `widget__clicked` is for widget interactions inside the same screen.

## Key properties to prioritize

Properties most useful for test analysis. Always include when relevant:

- `expr_id` — most precise anchor for the flow
- `current_screen`
- `owner`
- `provider`
- `flow`
- `entity_name`
- `experiment_name`
- `experiment_group` (a.k.a. `variant`)

## Tagging conventions

| Tag | Meaning |
|-----|---------|
| `[NEW]` | Value does not exist in production yet (new variant string, new widget id) |
| `[CONFIRM]` | Value guessed or partially matched; engineer must validate |
| `[NEEDS-HUMAN]` | Edge case — no existing event type fits; human must decide |

Every `[CONFIRM]` and `[NEEDS-HUMAN]` lands in the open-questions checklist at the bottom of the HTML proposal.

## Examples

### Example 1 — Reuse with new property values

```
Figma: New "Pix financing with credit" screen loads.
Decision: Rule 0 → screen__viewed. Rule 4 → reuse current_screen with new value.
Output:

  event: screen__viewed
  properties:
    current_screen: pix_no_credit_entrypoint_with_limit  [NEW]
    expr_id:        pix-financing-with-credit-widget    [CONFIRM]
    owner:          cc-financing
    provider:       finn
  rationale: Tracks loads of the new entrypoint screen so we can measure
             awareness of credit-backed Pix financing.
```

### Example 2 — A/B test, comparison table

```
Figma: PPF widget on financing hub. 3 cells (control, soft, hard).
Decision: Rule 3 → per-cell. Comparison table.
Output:

  event: widget__loaded
  | property         | control                     | soft                        | hard                        |
  | current_screen   | financing_hub               | financing_hub               | financing_hub               |
  | widget_type      | screen                      | screen                      | screen                      |
  | expr_id          | ppf-awareness-mx [CONFIRM]  | ppf-awareness-mx [CONFIRM]  | ppf-awareness-mx [CONFIRM]  |
  | variant          | control                     | soft                        | hard                        |
  | owner            | cc-financing                | cc-financing                | cc-financing                |
  rationale: Measures exposure — how many users in each cell are loaded with the PPF widget.
```

### Example 3 — Deeplink for tappable row

```
Figma: Row "See payment history" navigates to history flow.
Decision: Rule 6 → deeplink_clicked (NOT widget__clicked). tag identifies the row.
Output:

  event: deeplink_clicked
  properties:
    current_screen: financing_hub
    tag:            see_payment_history    [NEW]
    owner:          cc-financing
    provider:       finn
  rationale: Tracks navigation intent from the hub to the history flow so
             we can measure fan-out per cell.
```

## Lessons baked into these rules

1. **Delta-only docs.** Listing every screen and every existing event = noise.
2. **Reuse properties before adding new.** Real cost is noisy schemas.
3. **Right event for navigation.** `deeplink_clicked` for navigating rows.
4. **A/B cells mandatory — including control.** Without `variant` on every event you can't compare results.
5. **Comparison tables over per-cell blocks** when cells share the event but differ only in property values.
6. **Tag every value.** `[NEW]` / `[CONFIRM]` makes the review diff immediately clear.
7. **Rationale per event, not per screen.** "Measures awareness exposure" beats "tracks widget load".
8. **Open questions at the end.** Single numbered checklist; engineers sign off per item.
9. **Out of scope explicitly stated.** Prevents "what about X?" when X was considered and excluded.

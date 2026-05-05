# Decision tree

This is the human-facing reference. The proposer agent loads `skills/decision-tree/SKILL.md` (the machine-readable copy) at runtime — keep both files in sync if you change one.

## Overview

For every Figma node, the proposer answers four questions in order:

1. What kind of interaction is this?
2. Does an existing event already cover it (with different property values)?
3. Is this an A/B test? If so, define every event for every cell.
4. Is this a truly novel interaction with no NuDS# fit? If so, flag for human.

## Rule 1 — Default to NuDS# events

| Figma node | Default event |
|------------|---------------|
| Screen (top-level container loads) | `screen__viewed` (native) or `widget__loaded` (BDC widget) |
| Button (CTA) | `button__clicked` or `widget__clicked` |
| Widget (toggle, segmented, input) | `widget__clicked` |
| Row that navigates via deeplink | `deeplink_clicked` ← NOT `widget__clicked` |

## Rule 2 — Same screen, different flow

The same button can appear in two flows. Use the SAME event, different property values:

- `current_screen` — different parent screen
- `expr_id` — different experiment
- `entrypoint_type` — BDC vs native vs deeplink

## Rule 3 — New screen / button / interaction

Project introduces a new node not in any catalog?

- Use the appropriate NuDS# event (Rule 1)
- New property values (tag `[NEW]`)
- One-line **rationale**: what business question does this event answer?

Never invent a custom event type unless Rule 6.

## Rule 4 — A/B test cells (CRITICAL)

When `ab_test: true`:

- Every event MUST be defined for every cell, including `control`.
- Add a `variant` property (value = cell name).
- Without `variant` on every event, you cannot compare cells in Amplitude.
- Render shared-shape events as comparison tables (cells = columns).

## Rule 5 — Reuse properties before adding new

Before proposing a new property:

1. Look in `catalog/events.md` and `catalog/naming-conventions.md`.
2. Look at what existing events in production carry equivalent meaning.
3. Examples:
   - `financing_hub_options_group` differentiates Financing Hub variants. Reuse with a new value.
   - `entrypoint_type` differentiates BDC vs native. Do not invent `is_bdc`.

## Rule 6 — Edge case

When no NuDS# event covers the interaction (rare — e.g. server-side milestone with no UI affordance):

- Tag `[NEEDS-HUMAN]`.
- Stop on that node — do not auto-propose.
- Custom events incur per-event-type cost in Amplitude. Humans decide.

## Rule 7 — Delta-only documentation

Document ONLY what changes versus control. Do NOT list every existing event in every cell. Engineers need the diff, not the full state.

## Rule 8 — Choose the right event type for navigation

When a tappable row navigates to a new flow via deeplink → `deeplink_clicked` with a `tag` property identifying which option was tapped.

`deeplink_clicked` captures full navigation intent; `widget__clicked` is for widget interactions inside the same screen.

## Tagging conventions

| Tag | Meaning | Stripped at finalize? |
|-----|---------|----------------------|
| `[NEW]` | Value does not exist in production yet | no — preserved |
| `[CONFIRM]` | Value exists but needs engineer validation | yes |
| `[NEEDS-HUMAN]` | Edge case; human must decide | yes (after human resolves) |

Every `[CONFIRM]` and `[NEEDS-HUMAN]` lands in the open-questions checklist at the bottom of `proposed-events.md` so engineers can sign off per item.

## Examples

### Example 1 — Reuse with new property values

```
Figma: New "Pix financing with credit" screen loads.
Decision: Rule 1 → screen__viewed. Rule 3 → new property values.
Output:

  event: screen__viewed
  properties:
    current_screen: pix_no_credit_entrypoint_with_limit  [NEW]
    expr_id: pix-financing-with-credit-widget            [NEW]
    owner: cc-financing
    provider: finn
  rationale: Tracks loads of the new entrypoint screen so we can measure
             awareness of credit-backed Pix financing.
```

### Example 2 — A/B test, comparison table

```
Figma: PPF widget on financing hub. 3 cells (control, soft, hard).
Decision: Rule 4 → per-cell. Comparison table.
Output:

  event: widget__loaded
  | property         | control                        | soft                        | hard                        |
  | current_screen   | financing_hub                  | financing_hub               | financing_hub               |
  | widget_type      | screen                         | screen                      | screen                      |
  | expr_id          | ppf-awareness-mx        [CONFIRM] | ppf-awareness-mx [CONFIRM]  | ppf-awareness-mx  [CONFIRM] |
  | variant          | control                        | soft                        | hard                        |
  | owner            | cc-financing                   | cc-financing                | cc-financing                |
  rationale: Measures exposure — how many users in each cell are loaded with the PPF widget.
```

### Example 3 — Deeplink for tappable row

```
Figma: Row "See payment history" navigates to history flow.
Decision: Rule 1 → deeplink_clicked (NOT widget__clicked). tag identifies the row.
Output:

  event: deeplink_clicked
  properties:
    current_screen: financing_hub
    tag: see_payment_history    [NEW]
    owner: cc-financing
    provider: finn
  rationale: Tracks navigation intent from the hub to the history flow so
             we can measure fan-out per cell.
```

## PPF learnings (apply on every project)

These came out of the PPF Awareness Optimization pilot:

1. **Delta-only documentation.** Listing every screen and every existing event = noise. Engineers need to know what is new or different.
2. **Reuse properties before adding new ones.** Amplitude charges per event type, but the real cost is noisy schemas.
3. **Choose the right event type for navigation.** `deeplink_clicked` for navigating rows, not `widget__clicked`.
4. **A/B cells are mandatory — including control.** Without `variant` on every event, you cannot compare results.
5. **Comparison tables over per-cell blocks** when cells share the event but differ only in property values.
6. **Tag every new value.** `[NEW]` for not-yet-in-production, `[CONFIRM]` for needs-validation. Makes the review diff immediately clear.
7. **Rationale per event, not per screen.** "Measures awareness exposure — how many users in soft cells actually see the PPF widget" beats "tracks widget load".
8. **Open questions at the end.** Single numbered checklist. Engineers sign off per item.
9. **Out of scope explicitly stated.** Prevents "what about X?" when X was already considered and excluded.

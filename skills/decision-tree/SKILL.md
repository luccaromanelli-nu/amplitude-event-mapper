---
description: Encodes the NuDS# event reuse rules, A/B-cell rule, and PPF learnings. Loaded by the event-proposer to decide when to reuse vs propose new.
---

# Decision tree

This skill encodes the rules the proposer applies to every Figma node. Load it before generating a proposal.

## Rule 1 — Default to NuDS# events

For every Figma node classified as `screen`, `button`, `row`, or `widget`, the default event is one of:

| Figma type | Event |
|------------|-------|
| `screen` (top-level container loads) | `screen__viewed` or `widget__loaded` (when the screen is implemented as a widget) |
| `button` (CTA) | `button__clicked` or `widget__clicked` |
| `widget` (toggle, segmented control, input) | `widget__clicked` |
| `row` (tappable row that navigates) | `deeplink_clicked` (NOT `widget__clicked`) |

The differentiator is **properties**, not event type.

## Rule 2 — Required properties (NuDS# baseline)

Every NuDS# event includes:

- `current_screen` — string, the screen the user is on
- `entity_name` — string, the specific element (button label, widget id)
- `expr_id` — string, the experiment id (if applicable)
- `owner` — string, the squad that owns this surface
- `provider` — string, the BFF/BDC providing the screen (default `finn`)
- `package` — string, the BDC package (default `catalyst_entrypoint`)
- `entrypoint_type` — string, e.g. `bdc-widget`

For `deeplink_clicked`, also include:

- `tag` — string, identifies which option was tapped

## Rule 3 — Same screen, different flow

If the same Figma button appears in two flows (different parent screens or different experiments), use the SAME event type but vary `current_screen`, `expr_id`, or `entrypoint_type`. Do not invent a new event.

## Rule 4 — New screen / button / interaction

If the project introduces a screen, button, or row that does not exist anywhere in the catalog, propose:

- The appropriate NuDS# event (per Rule 1)
- New property values (tag with `[NEW]`)
- A one-line **rationale** explaining the business question the event answers (what comparison or measurement does it enable?)

Never propose a custom event type unless Rule 6 applies.

## Rule 5 — A/B test cells (CRITICAL)

When `ab_test: true`:

- Every event must be defined for every cell, including `control`.
- Add a `variant` property whose value is the cell name.
- Without a `variant` property on every event, results cannot be compared in Amplitude.

When cells share an event but differ only in property values, render them as a comparison table (one column per cell) instead of repeating the full event block.

## Rule 6 — Edge case (custom event needed)

Only when no NuDS# event covers the interaction (rare — e.g. a server-side milestone with no UI affordance):

- Tag `[NEEDS-HUMAN]`.
- Stop. Do not auto-propose.
- Custom events incur per-event-type cost in Amplitude. Humans decide.

## Rule 7 — Reuse properties before adding new

Before proposing a new property, check whether an existing property already carries equivalent meaning. Examples:

- `financing_hub_options_group` already differentiates Financing Hub variants — reuse with a new value rather than adding a new property
- `entrypoint_type` differentiates BDC vs native — do not invent `is_bdc`

## Rule 8 — Delta-only documentation

The proposal should describe ONLY what changes versus control. Do not list every existing event in every cell. Engineers need to know what is new or different — not what already works.

## Tagging conventions

| Tag | Meaning |
|-----|---------|
| `[NEW]` | This property value (or event) does not exist in production yet |
| `[CONFIRM]` | This value exists somewhere but needs engineer validation (e.g., we found two variants in different sources) |
| `[NEEDS-HUMAN]` | The proposer cannot decide; flagged for human review (Rule 6 cases) |

Collect every `[CONFIRM]` and `[NEEDS-HUMAN]` into a single numbered open-questions checklist at the bottom of the proposal so engineers can sign off per item.

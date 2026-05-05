# Event proposal — demo-ppf-mx

**Project:** demo-ppf-mx
**Country:** MX
**Experiment:** ppf-awareness-mx (cells: control, soft, hard)
**Scope:** PPF widget awareness optimization on the CC Financing hub. Test exposure-vs-engagement on three cells.

**Generated:** 2026-05-05
**Status:** Pending engineer review

---

## Summary

5 events proposed (1 reused with new property values, 4 new for soft/hard cells). The hub-level `widget__loaded` and `deeplink_clicked` events stay the same shape — we only add `expr_id` and `variant` so cells can be compared in Amplitude. New PPF-widget instrumentation lives in soft/hard only; control has no PPF surface. 4 `[CONFIRM]` items + 0 `[NEEDS-HUMAN]`.

---

## Out of scope

- Changes to the `widget__loaded` event firing on the hub itself in production today — we only add `expr_id` + `variant`, not a new event.
- The downstream `pix_financing_simulation`, `boleto_simulation`, `financing_history`, `ppf_explainer`, and `ppf_application` flows — instrumentation for those flows is owned by their respective squads and tracked separately.
- `request_error` events — no dynamic backend content in scope.

---

## Proposed events

### Event: `widget__loaded` — Financing hub load (per cell)

**Trigger:** Fires when the user lands on the Cash Flow Financing hub.
**Rationale:** Measures hub exposure per cell so we can compare reach across cells before any PPF interaction.

| Property | control | soft | hard |
|----------|---------|------|------|
| current_screen | `financing_hub` | `financing_hub` | `financing_hub` |
| widget_type | `screen` | `screen` | `screen` |
| expr_id | `ppf-awareness-mx` `[CONFIRM]` | `ppf-awareness-mx` `[CONFIRM]` | `ppf-awareness-mx` `[CONFIRM]` |
| variant | `control` | `soft` | `hard` |
| owner | `cc-financing` | `cc-financing` | `cc-financing` |
| provider | `finn` | `finn` | `finn` |
| package | `catalyst_entrypoint` | `catalyst_entrypoint` | `catalyst_entrypoint` |
| entrypoint_type | `bdc-widget` | `bdc-widget` | `bdc-widget` |

**Source(s):** Existing event ([Miro card](https://miro.example/board/demo-ppf-mx/card/m-1)) — only `expr_id` and `variant` added.

---

### Event: `widget__loaded` — PPF widget load (soft + hard only)

**Trigger:** Fires when the PPF widget renders on the hub. Control has no widget — no event.
**Rationale:** Measures awareness exposure — how many users in soft/hard cells actually see the PPF widget. This is the primary OKR signal for the experiment.

| Property | soft | hard |
|----------|------|------|
| current_screen | `financing_hub` | `financing_hub` |
| widget_type | `widget` `[NEW]` | `widget` `[NEW]` |
| entity_name | `ppf_widget` `[NEW]` | `ppf_widget` `[NEW]` |
| financing_hub_options_group | `ppf_soft` `[NEW]` | `ppf_hard` `[NEW]` |
| expr_id | `ppf-awareness-mx` `[CONFIRM]` | `ppf-awareness-mx` `[CONFIRM]` |
| variant | `soft` | `hard` |
| owner | `cc-financing` | `cc-financing` |
| provider | `finn` | `finn` |
| entrypoint_type | `bdc-widget` | `bdc-widget` |

**Source(s):** New (Tech Assessment).

---

### Event: `deeplink_clicked` — Hub row taps (per cell)

**Trigger:** Fires when the user taps a row that navigates away from the hub.
**Rationale:** Measures fan-out from the hub per cell. Comparing tap rates per row across cells tells us whether the PPF widget cannibalises taps on the existing rows.

| Property | control | soft | hard |
|----------|---------|------|------|
| current_screen | `financing_hub` | `financing_hub` | `financing_hub` |
| tag | `pix_financing` \| `boleto_financing` \| `financing_history` | (same) | (same) |
| expr_id | `ppf-awareness-mx` `[CONFIRM]` | `ppf-awareness-mx` `[CONFIRM]` | `ppf-awareness-mx` `[CONFIRM]` |
| variant | `control` | `soft` | `hard` |
| owner | `cc-financing` | `cc-financing` | `cc-financing` |
| provider | `finn` | `finn` | `finn` |

**Source(s):** Existing events ([Miro cards m-2/m-3/m-4](https://miro.example/board/demo-ppf-mx/card/m-2)) — only `expr_id` and `variant` added.

---

### Event: `widget__clicked` — Soft "Learn more" tap

**Trigger:** Fires when the user taps "Learn more" on the soft PPF widget.
**Rationale:** Measures engagement intent in soft — does an informational widget drive learn-more taps?

| Property | Value |
|----------|-------|
| current_screen | `financing_hub` |
| widget_type | `button` |
| entity_name | `ppf_learn_more` `[NEW]` |
| expr_id | `ppf-awareness-mx` |
| variant | `soft` |
| owner | `cc-financing` |
| provider | `finn` |
| entrypoint_type | `bdc-widget` |

**Source(s):** New (Tech Assessment).

---

### Event: `button__clicked` — Hard "Apply now" tap

**Trigger:** Fires when the user taps "Apply now" on the hard PPF widget.
**Rationale:** Measures the primary conversion action in hard — do users move directly into the application flow?

| Property | Value |
|----------|-------|
| current_screen | `financing_hub` |
| entity_name | `ppf_apply_now` `[NEW]` |
| expr_id | `ppf-awareness-mx` |
| variant | `hard` |
| owner | `cc-financing` |
| provider | `finn` |
| package | `catalyst_entrypoint` |

**Source(s):** New (Tech Assessment).

---

### Event: `widget__clicked` — Hard dismiss

**Trigger:** Fires when the user taps the dismiss button on the hard PPF widget.
**Rationale:** Measures avoidance — how many users in hard actively reject the widget.

| Property | Value |
|----------|-------|
| current_screen | `financing_hub` |
| widget_type | `button` |
| entity_name | `ppf_dismiss` `[NEW]` |
| expr_id | `ppf-awareness-mx` |
| variant | `hard` |
| owner | `cc-financing` |
| provider | `finn` |
| entrypoint_type | `bdc-widget` |

**Source(s):** New (Tech Assessment).

---

## Open questions (engineer sign-off checklist)

Resolve each before approving. Tick by replacing `[ ]` with `[x]` inline; the finalize step strips this section.

- [ ] 1. `[CONFIRM]` `widget__loaded.expr_id` value `ppf-awareness-mx` — confirm this matches the experiment id registered in the experimentation platform (current production firing has no `expr_id`).
- [ ] 2. `[CONFIRM]` `deeplink_clicked.expr_id` value `ppf-awareness-mx` — same as #1, confirm propagation to existing row events.
- [ ] 3. `[CONFIRM]` `widget__loaded.expr_id` (PPF widget) — confirm same `expr_id` is used here as on the hub-level event.
- [ ] 4. `[CONFIRM]` `financing_hub_options_group` values `ppf_soft` and `ppf_hard` — confirm these naming choices align with the existing taxonomy on the hub options property (or propose alternative).

---

## Approval

When every item above is ticked:

```bash
touch projects/demo-ppf-mx/APPROVED
```

Then re-run `/amplitude-event-mapper:propose demo-ppf-mx` (or `/amplitude-event-mapper:finalize demo-ppf-mx`) to promote this file to `final-event-map.md`.

# Final event map — demo-ppf-mx

**Finalized:** 2026-05-05
**Country:** MX
**Experiment:** ppf-awareness-mx (cells: control, soft, hard)
**Scope:** PPF widget awareness optimization on the CC Financing hub. Test exposure-vs-engagement on three cells.

> Approved. Confirm-tags stripped. New-value tags retained so engineers know which values are introduced for the first time.

---

## Events

### Event: `widget__loaded` — Financing hub load (per cell)

**Trigger:** Fires when the user lands on the Cash Flow Financing hub.
**Rationale:** Measures hub exposure per cell so we can compare reach across cells before any PPF interaction.

| Property | control | soft | hard |
|----------|---------|------|------|
| current_screen | `financing_hub` | `financing_hub` | `financing_hub` |
| widget_type | `screen` | `screen` | `screen` |
| expr_id | `ppf-awareness-mx` | `ppf-awareness-mx` | `ppf-awareness-mx` |
| variant | `control` | `soft` | `hard` |
| owner | `cc-financing` | `cc-financing` | `cc-financing` |
| provider | `finn` | `finn` | `finn` |
| package | `catalyst_entrypoint` | `catalyst_entrypoint` | `catalyst_entrypoint` |
| entrypoint_type | `bdc-widget` | `bdc-widget` | `bdc-widget` |

**Source(s):** Existing event — only `expr_id` and `variant` added.

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
| expr_id | `ppf-awareness-mx` | `ppf-awareness-mx` |
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
| expr_id | `ppf-awareness-mx` | `ppf-awareness-mx` | `ppf-awareness-mx` |
| variant | `control` | `soft` | `hard` |
| owner | `cc-financing` | `cc-financing` | `cc-financing` |
| provider | `finn` | `finn` | `finn` |

**Source(s):** Existing events — only `expr_id` and `variant` added.

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

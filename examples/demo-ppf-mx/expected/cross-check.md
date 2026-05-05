# Cross-check — demo-ppf-mx

**Generated:** 2026-05-05

Gap matrix between Figma screens (S), Miro/Confluence documentation (D), and live Amplitude firings (F).

---

## Stale or broken (documented but not firing)

| Event | Properties | Source | Last seen firing | Notes |
|-------|------------|--------|-------------------|-------|

_(none)_

---

## Undocumented (firing but not documented)

| Event | Properties | Firings (30d) | Action |
|-------|------------|---------------|--------|

_(none)_ — every firing event is also documented in Miro.

---

## Property mismatches

| Event | Property | Documented value | Firing value | Source of doc |
|-------|----------|-------------------|--------------|----------------|

_(none)_

---

## Uncovered Figma nodes

| Cell | Screen | Node | Type | Notes |
|------|--------|------|------|-------|
| soft | financing_hub | ppf_widget_soft | widget | New — needs `widget__loaded` per Tech Assessment |
| soft | financing_hub | btn_ppf_learn_more | button | New — needs `widget__clicked` |
| hard | financing_hub | ppf_widget_hard | widget | New — needs `widget__loaded` per Tech Assessment |
| hard | financing_hub | btn_ppf_apply_now | button | New — needs `button__clicked` |
| hard | financing_hub | btn_ppf_dismiss | button | New — needs `widget__clicked` |

---

## A/B coverage gap

| Event | Cells covered | Cells missing | Action |
|-------|---------------|---------------|--------|
| widget__loaded (financing_hub) | control, soft, hard (all firing) | — | Add `expr_id=ppf-awareness-mx` + `variant` to differentiate cells |
| deeplink_clicked (rows) | control, soft, hard (all firing) | — | Add `expr_id=ppf-awareness-mx` + `variant` to differentiate cells |
| widget__loaded (PPF widget) | — | control, soft, hard | Define for soft + hard (control has no widget) |
| widget__clicked (PPF Learn more) | — | soft | Define for soft only |
| button__clicked (PPF Apply now) | — | hard | Define for hard only |
| widget__clicked (PPF dismiss) | — | hard | Define for hard only |

---

## Summary

- Stale or broken: 0
- Undocumented: 0
- Mismatches: 0
- Uncovered Figma nodes: 5
- A/B coverage gaps: 6

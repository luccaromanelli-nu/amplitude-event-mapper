# PPF Awareness Optimization — Tech Assessment (synthetic demo)

> Synthetic Confluence fixture for the demo project. Not a real document.

## Goal

Test whether a more visible PPF entrypoint on the Cash Flow Financing hub increases application rate.

## Cells

- **control** — current hub, no PPF widget
- **soft** — small PPF widget with "Learn more" CTA
- **hard** — large PPF widget with "Apply now" CTA + dismiss

## Existing instrumentation (already firing)

| Event | Surface | Notes |
|-------|---------|-------|
| `widget__loaded` | financing_hub (hub load) | fires on every hub load |
| `deeplink_clicked` | rows in the hub | tag identifies which row |

## Proposed for this experiment

- New `widget__loaded` for the PPF widget itself (per cell, with `variant`)
- New `widget__clicked` for the soft cell's "Learn more" tap
- New `button__clicked` for the hard cell's "Apply now" tap
- New `widget__clicked` for the hard cell's dismiss button

All new events get `expr_id: ppf-awareness-mx` and `variant: <cell>`.

# Existing events — demo-ppf-mx

**Generated:** 2026-05-05

Normalized union of every event source. Sectioned by source.

## Figma screen inventory

| Cell | Screen | Node | Type | Navigates to |
|------|--------|------|------|--------------|
| control | financing_hub | Financing Hub | screen | — |
| control | financing_hub | row_pix_financing | row | pix_financing_simulation |
| control | financing_hub | row_boleto_financing | row | boleto_simulation |
| control | financing_hub | row_history | row | financing_history |
| soft | financing_hub | Financing Hub | screen | — |
| soft | financing_hub | row_pix_financing | row | pix_financing_simulation |
| soft | financing_hub | row_boleto_financing | row | boleto_simulation |
| soft | financing_hub | row_history | row | financing_history |
| soft | financing_hub | ppf_widget_soft | widget | — |
| soft | financing_hub | btn_ppf_learn_more | button | ppf_explainer |
| hard | financing_hub | Financing Hub | screen | — |
| hard | financing_hub | row_pix_financing | row | pix_financing_simulation |
| hard | financing_hub | row_boleto_financing | row | boleto_simulation |
| hard | financing_hub | row_history | row | financing_history |
| hard | financing_hub | ppf_widget_hard | widget | — |
| hard | financing_hub | btn_ppf_apply_now | button | ppf_application |
| hard | financing_hub | btn_ppf_dismiss | button | — |

## Miro documented events

| Event | Properties | Screen / flow | Source |
|-------|------------|---------------|--------|
| widget__loaded | current_screen=financing_hub, widget_type=screen, expr_id=financing-hub-mx.unified, owner=cc-financing, provider=finn, package=catalyst_entrypoint, entrypoint_type=bdc-widget | Hub load | [card](https://miro.example/board/demo-ppf-mx/card/m-1) |
| deeplink_clicked | current_screen=financing_hub, tag=pix_financing, owner=cc-financing, provider=finn | Pix financing row | [card](https://miro.example/board/demo-ppf-mx/card/m-2) |
| deeplink_clicked | current_screen=financing_hub, tag=boleto_financing, owner=cc-financing, provider=finn | Boleto financing row | [card](https://miro.example/board/demo-ppf-mx/card/m-3) |
| deeplink_clicked | current_screen=financing_hub, tag=financing_history, owner=cc-financing, provider=finn | History row | [card](https://miro.example/board/demo-ppf-mx/card/m-4) |

## Confluence documented events

| Event | Properties | Doc type | Rationale | Source |
|-------|------------|----------|-----------|--------|
| _(none documented as currently firing — Tech Assessment lists only proposals)_ |  |  |  |  |

## Amplitude (production)

| Event | current_screen | expr_id | variant | tag | owner | provider | Firings (30d) |
|-------|----------------|---------|---------|-----|-------|----------|---------------|
| widget__loaded | financing_hub | financing-hub-mx.unified | — | — | cc-financing | finn | 142,331 |
| deeplink_clicked | financing_hub | — | — | pix_financing | cc-financing | finn | 88,412 |
| deeplink_clicked | financing_hub | — | — | boleto_financing | cc-financing | finn | 41,287 |
| deeplink_clicked | financing_hub | — | — | financing_history | cc-financing | finn | 22,119 |

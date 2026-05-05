# Naming conventions

## Event names

- Use NuDS# canonical events (`widget__loaded`, `widget__clicked`, `screen__viewed`, `button__clicked`, `deeplink_clicked`, `request_error`).
- Custom event types are discouraged — Amplitude charges per type. Use property values to differentiate.
- If you must propose a custom event, tag `[NEEDS-HUMAN]` and stop.

## Property names

- snake_case. Lowercase only. ASCII.
- Use existing property names before inventing new ones. Examples of widely-used properties: `current_screen`, `entity_name`, `expr_id`, `owner`, `provider`, `package`, `package_owner`, `entrypoint_type`, `variant`, `tag`, `widget_type`, `financing_hub_options_group`.
- Do not invent boolean properties when an existing enum already covers the meaning (e.g. do not add `is_bdc` when `entrypoint_type` already differentiates).

## Property values

- snake_case for screen names, expr_ids, entity names.
- Lowercase ASCII.
- For experiment ids, use the format `<surface>-<feature>.<scope>` (e.g. `pix-financing-unified.installments`).
- For A/B variants, use the cell name verbatim (`control`, `soft`, `hard`, `treatment`).

## A/B test variant property

Always use a property named `variant`. Always include `control`. Cells without `variant` cannot be compared in Amplitude.

## Owner / provider conventions

- `owner` — the squad responsible. snake_case or kebab-case (e.g. `cc-financing`, `financing-experience`).
- `provider` — the BFF/BDC service serving the screen. lowercase (e.g. `finn`, `cashier`).

## current_screen conventions

- snake_case.
- Should be readable in isolation (`pix_no_credit_entrypoint_with_limit` rather than `screen_42`).
- For modals, suffix `_modal`. For bottom sheets, suffix `_sheet`. For empty states, suffix `_empty`.

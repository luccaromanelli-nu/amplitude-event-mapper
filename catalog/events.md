# Catalog — canonical NuDS# events

This is the seed catalog of Amplitude events used across Nubank surfaces. The proposer references this file to pick the right event type for a given Figma node.

> **Read-only.** The plugin never modifies this file. Promotions from project-level proposals are reviewed and applied separately.

## Events

### `screen__viewed`

Fires when a top-level screen is loaded. Use for native screens.

**Required properties:**

- `current_screen` — string, snake_case screen name
- `expr_id` — string, experiment id (when applicable)
- `owner` — string, squad
- `provider` — string, BFF/BDC

**Optional:**

- `package_owner`, `package`, `entrypoint_type`, `variant`

---

### `widget__loaded`

Fires when a screen implemented as a BDC widget loads.

**Required properties:**

- `current_screen`
- `widget_type` — usually `screen`
- `expr_id`
- `owner`
- `provider`
- `package` (default `catalyst_entrypoint`)
- `entrypoint_type` (default `bdc-widget`)

**Optional:** `variant`

---

### `widget__clicked`

Fires when a non-button widget is interacted with (toggle, segmented control, input).

**Required properties:**

- `current_screen`
- `widget_type` — `button` | `toggle` | `input` | etc.
- `entity_name` — element identifier
- `expr_id`
- `owner`
- `provider`
- `entrypoint_type`

**Optional:** `variant`

---

### `button__clicked`

Fires when a CTA button is tapped.

**Required properties:**

- `current_screen`
- `entity_name` — button label or id
- `expr_id`
- `owner`
- `provider`

**Optional:** `package`, `package_owner`, `variant`

---

### `deeplink_clicked`

Fires when a tappable row navigates to another flow via deeplink. Captures full navigation intent.

**Required properties:**

- `current_screen` — where the user is coming from
- `tag` — identifies which option was tapped
- `owner`
- `provider`

**Optional:** `expr_id`, `variant`, `entrypoint_type`

> **Use this — not `widget__clicked` — for navigating rows.**

---

### `request_error`

Fires when backend-loaded content fails. Only emit when content is fetched dynamically and failure changes the user's experience.

**Required properties:**

- `current_screen`
- `error_code`
- `error_source` — service name
- `owner`
- `provider`

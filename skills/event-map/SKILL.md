---
name: event-map
description: Generate a self-contained HTML Amplitude event-mapping proposal from a Figma file, a PRD, and the existing analytics in code (via Glean). Reuses existing event types only; proposes new property values. Use when the user invokes /event-map or asks to build an event proposal from Figma+PRD.
---

# event-map skill

Single skill that produces `projects/<slug>/proposal.html` from a Figma file, a PRD, and the existing instrumentation in code.

## Hard rules

1. **Never propose a new event type.** Reuse `screen__viewed`, `button__clicked`, `widget__clicked`, `deeplink_clicked`, etc. only. If no existing type fits, tag `[NEEDS-HUMAN]` and surface in Open Questions.
2. **Cite code for every reused event.** Every event block must carry a `Reuse — found in <repo>:<file>:<line>` line, sourced from Glean. If no citation can be found, tag `[CONFIRM]` and explain in the citation footer.
3. **`expr_id` is the anchor.** Extract the literal value from code. Missing → `[CONFIRM]`.
4. **Pause at four confirm gates** (defined below). Use `AskUserQuestion` — never silent guesses.
5. **Read-only.** Only writes allowed: `projects/<slug>/proposal.html` and (optionally) `projects/<slug>/assets/*.png`. Never call Slack send, Jira create/edit/comment, Confluence create/edit, Drive write/move/rename/delete.
6. **Decision tree** at `docs/decision-tree.md` is authoritative. Re-read on every run.

## Inputs

```
/event-map [figma_url] [prd_url] [metrics_url]
```

- `figma_url` (required) — link to a Figma file/frame
- `prd_url` (required) — Google Doc, Confluence page, web URL, or local file path
- `metrics_url` (optional) — slide deck or doc describing the analyses the team wants to run

Missing required arg → `AskUserQuestion`.

## Step-by-step

### Step 0 — Verify MCPs

- Figma MCP must be available (project `.mcp.json` registers it). If absent → abort with: "Set FIGMA_TOKEN env var and reload the plugin."
- Glean MCP must be available (`mcp__glean_default__*` and/or `mcp__glean_agents__*`). If absent → abort with: "Install Glean MCP at the user level — see https://help.glean.com/mcp."

### Step 1 — Collect inputs

Read CLI args. For any missing required arg, call `AskUserQuestion` with one question per missing input. Default `metrics_url` to none.

### Step 2 — Fetch sources in parallel

Call these in a single message with multiple tool uses:

- **Figma** — fetch frame tree starting at the URL's node ID. Two transport options, in order of preference:
  1. **Figma MCP** if `mcp__figma__*` tools are available.
  2. **Figma REST API direct** as fallback (use when MCP not loaded but `FIGMA_TOKEN` is set, or the user pasted a token):
     - `GET https://api.figma.com/v1/files/{file_key}/nodes?ids={node_id}&depth=10` with header `X-FIGMA-TOKEN: <token>`
     - Cache the response in `/tmp/event-map-cache/figma.json`.
     - File key + node id are parsed from the URL: `https://www.figma.com/design/{file_key}/...?node-id={node-id}` (convert `1978-20184` → `1978:20184`).
  3. If neither MCP nor token is available, abort with: "Set `FIGMA_TOKEN` env var (`export FIGMA_TOKEN=...` in `~/.zshrc`) or install the Figma MCP."
  - When the user pastes a token in chat, persist it to `~/.zshrc` (`export FIGMA_TOKEN=...`) so future runs work — confirm with the user before writing if they have not already asked.
- **PRD** — pick the right tool based on URL:
  - `docs.google.com` → `mcp__google-workspace__docs_getText`. If that errors with a field-mask comment error, fall back to `mcp__glean_default__read_document` with the doc URL (returns the doc body via Glean's mirror).
  - Confluence (`*.atlassian.net/wiki/`) → `mcp__Atlassian__getConfluencePage`
  - http(s) other → `WebFetch` with prompt: "Return full text. Preserve headings and bullet lists."
  - local path → `Read`
- **Metrics** (if supplied) — same routing as PRD.

#### Step 2a — Always render Figma screen images (HARD)

Every changing-screen section in the final HTML MUST include a row of phone-style Figma screenshots — one per cell that visually differs. This is non-negotiable: a written proposal without the visual deltas wastes the engineer's review time.

For each section:
1. Identify the representative frame ID per cell from the Figma node tree (look for FRAME children whose names are numeric and whose parents are SECTIONs matching the cell label).
2. Batch-fetch render URLs with the Figma image API (single call, all IDs):
   ```
   GET https://api.figma.com/v1/images/{file_key}?ids=ID1,ID2,...&format=png&scale=1
   ```
3. Download each PNG to `projects/<slug>/assets/<cell-slug>-<screen-slug>.png`.
4. Reference them in the HTML via a `<div class="figma-screens">` row at the top of each section, using the `figma-phone` markup defined in the template's CSS:
   ```html
   <div class="figma-screens">
     <div class="figma-phone">
       <img src="assets/<cell>-<screen>.png" alt="<screen> — <cell>">
       <div class="figma-phone-label"><cell></div>
       <div class="figma-phone-sub"><one-line delta></div>
     </div>
     <!-- one figma-phone per cell -->
   </div>
   ```

Default mode = relative paths (`assets/...png`). The HTML + assets directory together ARE the deliverable; the template uses relative paths and the proposal opens locally without rebuilds.

If a cell has no visual change for that screen (e.g., back button identical across cells), still include one representative phone for the screen and label it `all cells — same`. Never skip the screenshots row.

Extract from the PRD:
- project title and country
- hypothesis / what the team wants to measure
- A/B cell list and naming
- placements per cell
- out-of-scope bullets
- analyst name (often the doc author)

### Step 3 — Identify changing screens

Compare Figma frame names + PRD scope. Build a list of `(screen, change_summary)` tuples. Drop frames with no change.

### Step 4 — Glean code search

Default repo: `nubank/finn` (CC Financing). Confirm with user if uncertain — `AskUserQuestion` listing the inferred repo + an "other" escape.

For each changing screen, query Glean for:
- the screen identifier (kebab/snake/PascalCase variants)
- prominent button labels
- widget keys
- the hypothesis title from the PRD (sometimes the `expr_id` matches it)

Collect candidate hits as `(repo, file, line, snippet)`.

#### Confirm gate 1 — flow location

Present findings:

```
Found candidate flow file(s):
  finn:src/financing_hub/screen.cljc:142   (snippet…)
  finn:src/maquininha/payment_select.cljc:88   (snippet…)
Are these the right flows?
```

Use `AskUserQuestion` — yes / no / pick subset / paste exact path.

### Step 5 — Extract instrumentation

From confirmed code locations, extract:
- `expr_id` — literal string after the `:expr_id` key
- `:analytics-context` — full map (flow-level base properties)
- `:button-analytics-props` — every occurrence
- direct event calls (`analytics/track`, `track-event!`, etc.)

Record `repo:file:line` for every value.

#### Confirm gate 2 — instrumentation

Show a compact summary:

```
expr_id:                ppf-awareness-mx-2026   (finn:src/financing_hub/screen.cljc:142)
:analytics-context:
  current_screen:       financing_hub          (…:148)
  owner:                cc-financing           (…:149)
  provider:             finn                   (…:150)
  flow:                 ppf_awareness          (…:151)
:button-analytics-props (3 occurrences)
direct event calls:     widget__loaded (1), button__clicked (4)
```

`AskUserQuestion`: "Existing instrumentation matches what you expect?" — yes / no (paste corrections) / partial (specify gaps).

### Step 6 — Reconcile cells/variants

- Cell list from Figma frame names vs PRD.
- Match → proceed.
- Mismatch → confirm gate 3 (`AskUserQuestion`: list both, ask which to use or write a custom list).
- Auto-detect holdout: PRD wording (`removal`, `holdout`, `no PPF`, `no widget`) or empty/blank Figma frame.

### Step 7 — Resolve measurement intent

Use the PRD + metrics deck (if present) to identify what the team wants to measure. For each:

- variant the user saw → propose `variant` / `experiment_group`
- which CTA was clicked → propose new `entity_name` value on `button__clicked`
- which entry point was used → propose new `entrypoint_type` value
- which screen reached → propose new `current_screen` value
- which experimental segment → propose new `experiment_name` / `experiment_group` value

If intent is ambiguous after both sources → confirm gate 4 (`AskUserQuestion`).

### Step 8 — Apply decision tree

Re-read `docs/decision-tree.md`. For each Figma delta:
- pick the existing event type (Rule 0).
- prefer existing properties already in `:analytics-context` (Rule 4).
- mark each value:
  - `[NEW]` — value clearly absent from production
  - `[CONFIRM]` — value guessed or partially matched
  - `[NEEDS-HUMAN]` — no event type fits

Aggregate every `[CONFIRM]` and `[NEEDS-HUMAN]` into the Open Questions list.

### Step 9 — Render HTML

Read `templates/proposal.html.tmpl`. Fill slots:

| Slot | Value |
|------|-------|
| `{{PROJECT_TITLE}}` | from PRD |
| `{{COUNTRY}}` / `{{COUNTRY_LONG}}` | e.g. MX / Mexico |
| `{{STATUS_LABEL}}` | `Draft — awaiting engineer review` |
| `{{HERO_TITLE_LINE1}}` / `{{HERO_TITLE_LINE2}}` | project name split for the purple-color second line |
| `{{HERO_SUBTITLE}}` | one-sentence summary from PRD |
| `{{META_ITEMS}}` | rendered HTML for date / country / expr_id / status / owner / analyst / Figma link / PRD link |
| `{{CELL_COUNT}}` | integer |
| `{{TEST_TABLE_ROWS}}` | `<tr>` per cell with badge + figma name + placement + what's new |
| `{{VARIANT_NOTE}}` | one-sentence note about cell naming convention (always tagged `[CONFIRM]` if guessed) |
| `{{FLOW_MAP}}` | ASCII flow diagram (one line per cell branch) inside `<div class="flow-map">` |
| `{{SECTIONS}}` | one `<div class="section">` per changing screen with side-by-side cell screenshots and event blocks (template below) |
| `{{OPEN_QUESTIONS}}` | `<li><span class="q-num">N</span>question text</li>` per `[CONFIRM]` / `[NEEDS-HUMAN]` |
| `{{OUT_OF_SCOPE}}` | `<li><strong>X</strong> — explanation</li>` per PRD out-of-scope bullet |

#### Event block template (used inside each `{{SECTIONS}}` entry)

```html
<div class="event-block">
  <div class="event-block-header">
    <div style="display:flex;align-items:center;gap:10px;">
      <div class="event-name">EVENT_NAME</div>
      <div class="event-rationale">ONE_LINE_RATIONALE</div>
    </div>
    <span class="event-reuse-badge">Reuse — new property values</span>
  </div>

  <table class="prop-table">
    <thead>
      <tr>
        <th>Property</th>
        <th><span class="cell-badge cell-control">control</span></th>
        <!-- one column per non-control cell -->
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="prop-key">PROP_NAME</td>
        <td><span class="prop-val">VALUE</span> [optional tag]</td>
        <!-- per-cell columns -->
      </tr>
    </tbody>
  </table>

  <div class="code-citation">
    Reuse — found in <a href="GLEAN_LINK"><code>REPO:FILE:LINE</code></a>
  </div>
</div>
```

If no code citation could be sourced for a given event, replace the citation footer with:

```html
<div class="code-citation"><span class="miss">No code citation found — confirm with engineer.</span></div>
```

### Step 10 — Write file

Write the filled HTML to `projects/<slug>/proposal.html`. Slug rule: kebab-case of PRD title + `-<country-lowercase>` if country known. Examples: `ppf-awareness-optimization-mx`.

Cell PNGs MUST be present (see Step 2a). Default mode: write to `projects/<slug>/assets/<cell>-<screen>.png` and reference relatively from the HTML. The `assets/` dir + HTML together are the deliverable. Do not skip the `figma-screens` rows.

Print:
```
Wrote projects/<slug>/proposal.html
Open with: open projects/<slug>/proposal.html
```

## Failure modes

| Symptom | Action |
|---------|--------|
| Figma MCP returns no node tree | Abort. Tell user to verify URL and `FIGMA_TOKEN`. |
| PRD URL unreachable | Ask user to paste content or supply alternate URL. |
| Glean returns 0 hits for a screen | Mark every event in that screen `[CONFIRM]`. Add an Open Question: "Could not locate flow in code — confirm `expr_id` and existing properties." |
| Cell list cannot be reconciled even after gate 3 | Use the user's pasted list verbatim. Tag `[CONFIRM]` on every variant value. |
| User aborts at any confirm gate | Stop. Do not write the HTML. Report which gate failed. |

## Verification (quick smoke)

After writing the file:

1. Confirm `<title>` contains the project title and country.
2. Confirm at least one `<div class="event-block">` per changing screen.
3. Confirm every event-block has either `<div class="code-citation">` with a real `repo:file:line` or `class="miss"`.
4. Confirm no event name in the HTML is outside the existing taxonomy (`screen__viewed`, `widget__loaded`, `widget__clicked`, `button__clicked`, `deeplink_clicked`, `request_error` — extend only if Glean confirms it exists).
5. Confirm Open Questions count ≥ count of distinct `[CONFIRM]` / `[NEEDS-HUMAN]` themes (multiple tags may roll up into one question).
6. **Confirm every per-screen section has a `<div class="figma-screens">` row with at least one `<img src="assets/...png">`.** If a section is missing screenshots, the proposal is incomplete — re-run Step 2a for that section before reporting done.
7. Confirm `projects/<slug>/assets/` exists and contains a PNG for every `<img>` referenced in the HTML.

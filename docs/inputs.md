# Inputs — `input.yaml`

Every project lives at `projects/<project_name>/`. The orchestrator reads `projects/<project_name>/input.yaml` to drive the pipeline.

A starter is at `templates/input-template.yaml`. Copy it:

```bash
mkdir -p projects/<project_name>
cp templates/input-template.yaml projects/<project_name>/input.yaml
$EDITOR projects/<project_name>/input.yaml
```

## Schema

```yaml
project_name: <slug>           # required — short kebab-case slug used as the directory name
scope: |                       # required — 2-3 sentences describing what's in scope
  <free-text>
country: BR                    # required — BR | MX | CO

ab_test: false                 # optional — true for experiments
expr_id: <experiment-id>       # required when ab_test=true
cells:                         # required when ab_test=true; MUST include control
  - control
  - <variant>

sources:
  figma:                       # required — at least one URL or fixture path
    - <figma URL>
  miro:                        # optional
    - <miro board URL>
  confluence:                  # optional
    - <confluence page URL>

squad: <squad>                 # optional — used to scope Confluence search if URL list is empty
owner: <owner>                 # optional — default value for the `owner` property

default_provider: finn               # optional — default for the `provider` property
default_package: catalyst_entrypoint # optional
default_entrypoint_type: bdc-widget  # optional
```

## Field reference

### `project_name` (required)

Short kebab-case slug. This is the directory name under `projects/`. Examples: `ppf-awareness-mx`, `pix-financing-redesign`, `boleto-cap-rollout`.

### `scope` (required)

2-3 sentences. Reviewers (and the proposer) use this to understand what's in versus out. Be specific about surfaces and flows.

Bad: `Improve PPF`.
Good: `PPF widget awareness optimization on Cash Flow Financing hub. Test exposure-vs-engagement on three cells (control, soft, hard). MX only.`

### `country` (required)

`BR` | `MX` | `CO`. Drives:

- Databricks table names (`magnitude.<country>.amplitude_events`)
- Default naming conventions
- Default `owner` and `provider` values

### `ab_test` and `cells` (conditional)

When `ab_test: true`:

- `cells` MUST include `control`.
- `expr_id` MUST be set.
- Every proposed event will be defined for every cell with a `variant` property.

When `ab_test: false`:

- The proposer treats this as a feature launch and skips per-cell expansion.

### `sources.figma` (required)

URLs to Figma file(s) or specific frames. For A/B tests where each cell has its own Figma frame, list one URL per cell in the same order as `cells`.

The figma-walker enumerates every frame, screen, button, row, and widget in scope.

### `sources.miro` (optional)

URLs to Miro boards documenting events for this product area. The miro-event-fetcher extracts event cards from each board.

### `sources.confluence` (optional)

URLs to specific Confluence pages (RFCs, tech assessments, existing event docs). When empty, the confluence-event-fetcher falls back to a search using `squad` as the term.

### `squad` and `owner` (optional)

`squad` — used as the search term for Confluence fallback search.
`owner` — used as the default value of the `owner` property in proposed events.

### Defaults (optional)

`default_provider`, `default_package`, `default_entrypoint_type` — applied to NuDS# event property defaults when no other source overrides. Useful when working outside CC Financing (which defaults to `finn` / `catalyst_entrypoint` / `bdc-widget`).

## Example — A/B test (PPF MX)

```yaml
project_name: ppf-awareness-mx
scope: |
  PPF widget awareness optimization on Cash Flow Financing hub.
  Test exposure-vs-engagement on three cells.
country: MX
ab_test: true
expr_id: ppf-awareness-mx
cells: [control, soft, hard]
sources:
  figma:
    - https://figma.com/file/abc/control
    - https://figma.com/file/abc/soft
    - https://figma.com/file/abc/hard
  miro:
    - https://miro.com/app/board/o9J_kEXo2dE=/
  confluence:
    - https://nubank.atlassian.net/wiki/spaces/AB/pages/123456/PPF+Awareness+RFC
squad: cc-financing
owner: cc-financing
```

## Example — feature launch (no A/B)

```yaml
project_name: boleto-cap-rollout
scope: |
  Launch of dynamic CAP for boleto financing in BR.
  New screen for cap explanation; reuses existing simulation flow otherwise.
country: BR
ab_test: false
sources:
  figma:
    - https://figma.com/file/def/boleto-cap
  confluence:
    - https://nubank.atlassian.net/wiki/spaces/CCFIN/pages/789012
squad: cc-financing
owner: cc-financing
```

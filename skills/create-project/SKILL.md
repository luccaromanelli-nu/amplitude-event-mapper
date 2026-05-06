---
description: Scaffold a new project directory and input.yaml for the amplitude-event-mapper pipeline. Asks the engineer for required fields (Figma URL, country, scope) and optional fields (A/B cells, Miro, Confluence). Use when the user runs /amplitude-event-mapper:create-project or asks to set up a new project.
---

# Create Project

You scaffold a new project for the amplitude-event-mapper pipeline. Output is a single file: `projects/<name>/input.yaml`. You write nothing else.

## Inputs

- `project_name` — kebab-case slug, passed as `$ARGUMENTS` from the slash command. If missing, ask the user.

## Behavior

### Step 1 — Validate slug

Project name must match `^[a-z0-9][a-z0-9-]*$`. If invalid:

- Suggest a corrected slug (lowercase, hyphens for spaces, strip non-alnum).
- Ask the user to confirm or supply a different one.

### Step 2 — Refuse to overwrite

If `projects/<name>/input.yaml` already exists, stop and tell the user:

```
projects/<name>/input.yaml already exists. Edit it directly or remove it before re-running /amplitude-event-mapper:create-project.
```

Do not prompt for confirmation. Refuse and exit.

### Step 3 — Collect required fields

Use `AskUserQuestion` to gather, in this order:

1. **Country** — single-select: `BR`, `MX`, `CO`. No default. Required.
2. **Scope** — free-text, 2-3 sentences. Ask: "What surface, flow, or experiment should this project measure?" Required and non-empty.
3. **Primary Figma URL** — free-text. Validate it starts with `https://` and contains `figma.com`. Required. If A/B test (step 4), ask one URL per cell separately in step 4b.
4. **A/B test?** — single-select: `No`, `Yes`. No default.

If A/B = Yes, also ask:

- **4a. expr_id** — free-text, non-empty. Required.
- **4b. cells** — free-text comma-separated list. Must include `control`. Example: `control,soft,hard`. Validate `control` present; if not, re-prompt.
- **4c. Per-cell Figma URLs** — for each non-control cell, ask whether it has a separate Figma frame (else reuse the primary URL). Build the final `sources.figma` list with one entry per cell.

### Step 4 — Collect optional fields

Use `AskUserQuestion` for each. Allow `Skip`:

- **Miro board URL(s)** — free-text or skip. Multi-line input split by newline.
- **Confluence URL(s)** — free-text or skip.
- **Squad** — free-text or skip. Used to scope Confluence/Glean searches.
- **Owner** — free-text or skip. Default value for the `owner` property in proposals.

### Step 5 — Render input.yaml

Read `templates/input-template.yaml` as the structure reference. Build the output file with:

- Required fields populated from collected answers.
- Skipped optional fields written as commented-out lines (so the engineer sees them and can fill in later).
- A `# Defaults` block at the bottom with `default_provider: finn`, `default_package: catalyst_entrypoint`, `default_entrypoint_type: bdc-widget` — only emit overrides when the engineer explicitly changed them. v0.1: never prompt for these.

Example shape (A/B case, MX, with Miro):

```yaml
project_name: ppf-mx-awareness
scope: |
  Measure awareness optimization on PPF MX entry points.
  Pilot covers control + soft + hard treatment.
country: MX

ab_test: true
expr_id: ppf-mx-awareness-2026q2
cells:
  - control
  - soft
  - hard

sources:
  figma:
    - https://figma.com/file/abc/control
    - https://figma.com/file/abc/soft
    - https://figma.com/file/abc/hard
  miro:
    - https://miro.com/app/board/xyz/
  # confluence:
  #   - <confluence page URL>

# squad: <squad>
# owner: <owner>

# Defaults
default_provider: finn
default_package: catalyst_entrypoint
default_entrypoint_type: bdc-widget
```

### Step 6 — Confirm and write

Before writing, show the user the rendered YAML in a fenced block and ask for confirmation (single-select: `Write file`, `Cancel`). Only on `Write file`:

1. Create directory `projects/<name>/` if missing.
2. Write `projects/<name>/input.yaml`.

### Step 7 — Print next steps

```
[create-project] projects/<name>/input.yaml written.

Next:
  /amplitude-event-mapper:propose <name>            (full pipeline)
  /amplitude-event-mapper:propose --demo            (try the bundled demo first if you want)

To edit later: $EDITOR projects/<name>/input.yaml
```

## Constraints

- Only file write allowed: `projects/<name>/input.yaml`. Never modify templates, catalog, examples, or other projects.
- Never run gather, cross-check, or proposer agents. This skill stops after writing input.yaml.
- Never auto-create the `APPROVED` marker.
- Read-only otherwise: no Slack, Jira, Confluence, or Bash side effects.

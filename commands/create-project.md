---
description: Scaffold a new project directory and input.yaml. Interactive — prompts for Figma URL, country, scope, optional A/B cells, Miro, Confluence.
---

# /amplitude-event-mapper:create-project

Scaffold `projects/<name>/input.yaml` for a new project. First step of the pipeline.

## Usage

```
/amplitude-event-mapper:create-project <project-name>
```

Project arg: `$ARGUMENTS`

## Behavior

1. If `$ARGUMENTS` empty, ask the user for a kebab-case project slug.
2. Validate slug (`^[a-z0-9][a-z0-9-]*$`). Suggest correction if invalid.
3. Refuse to overwrite if `projects/<name>/input.yaml` already exists.
4. Invoke the `create-project` skill, which:
   - Asks for required fields: country, scope, Figma URL, A/B (yes/no, cells, expr_id).
   - Asks for optional fields: Miro URLs, Confluence URLs, squad, owner.
   - Renders YAML, shows preview, asks to confirm.
   - Writes `projects/<name>/input.yaml`.

## Output

- `projects/<name>/input.yaml`

## Next step

```
/amplitude-event-mapper:propose <name>
```

## Side effects

None outside `projects/<name>/`. Hook layer denies all write tools by default.

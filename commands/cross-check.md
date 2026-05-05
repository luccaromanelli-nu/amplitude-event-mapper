---
description: Re-run only the cross-check phase against existing gather output. Use after engineer feedback updates.
---

# /amplitude-event-mapper:cross-check

Re-run the cross-check phase against the gather output already in `projects/<project>/existing-events.md`. Useful when engineers correct or annotate the gather output and you want a fresh gap matrix without re-pulling Figma/Miro/Databricks.

## Usage

```
/amplitude-event-mapper:cross-check <project-name>
```

Project arg: `$ARGUMENTS`

## Behavior

1. Read `projects/$ARGUMENTS/existing-events.md` (must exist).
2. Read `projects/$ARGUMENTS/input.yaml` for the Figma screen inventory reference.
3. Invoke the event-cross-checker agent.
4. Write `projects/<project>/cross-check.md`.

## Output

- `projects/<project>/cross-check.md` (overwritten)

Does not modify `existing-events.md` or any other file.

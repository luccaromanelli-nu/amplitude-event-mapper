---
description: Regenerate the proposal from existing gather + cross-check output. Use after manual edits to existing-events.md or cross-check.md.
---

# /amplitude-event-mapper:propose-only

Regenerate the proposal from existing gather + cross-check output. Skips gather and cross-check phases.

## Usage

```
/amplitude-event-mapper:propose-only <project-name>
```

Project arg: `$ARGUMENTS`

## Behavior

1. Read `projects/$ARGUMENTS/existing-events.md` and `projects/$ARGUMENTS/cross-check.md` (both must exist).
2. Read `projects/$ARGUMENTS/input.yaml` for cell list and project metadata.
3. Invoke the event-proposer agent (applies the decision tree).
4. Invoke the format-proposal skill to render the final markdown.
5. Write `projects/<project>/proposed-events.md`.

## Output

- `projects/<project>/proposed-events.md` (overwritten)

Does not run gather or cross-check.

---
description: Promote an approved proposal to final-event-map.md. Requires the APPROVED marker file.
---

# /amplitude-event-mapper:finalize

Promote `proposed-events.md` to `final-event-map.md`. Requires the engineer to have created the `APPROVED` marker.

## Usage

```
/amplitude-event-mapper:finalize <project-name>
```

Project arg: `$ARGUMENTS`

## Behavior

1. Verify `projects/$ARGUMENTS/APPROVED` exists. If absent, refuse and instruct the user to create it after reviewing `proposed-events.md`.
2. Verify `projects/$ARGUMENTS/proposed-events.md` exists.
3. Invoke the finalize skill, which:
   - Strips `[CONFIRM]` tags from values still flagged (these become hard requirements).
   - Preserves `[NEW]` tags so engineers know what is being introduced for the first time.
   - Adds a "Finalized: YYYY-MM-DD" header.
   - Writes `projects/<project>/final-event-map.md`.
4. Refuse to overwrite an existing `final-event-map.md` unless the user explicitly confirms.

## Output

- `projects/<project>/final-event-map.md`

## Side effects

None. The marker file is read-only from the plugin's perspective.

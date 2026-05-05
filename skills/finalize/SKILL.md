---
description: Promote an APPROVED proposal to final-event-map.md. Strips [CONFIRM] tags, preserves [NEW] tags, and adds a finalized header.
---

# Finalize

You promote `proposed-events.md` to `final-event-map.md` after the engineer has approved.

## Inputs

- `projects/<project>/APPROVED` — must exist (any contents).
- `projects/<project>/proposed-events.md` — must exist.

## Behavior

1. Verify both inputs exist. If `APPROVED` is missing, refuse with a clear message: "No APPROVED marker. Engineers must review proposed-events.md, resolve [CONFIRM] items, and then `touch projects/<project>/APPROVED`."
2. Refuse to overwrite an existing `final-event-map.md` unless the user explicitly confirms in the conversation.
3. Read `proposed-events.md`.
4. Apply transformations:
   - Strip every `[CONFIRM]` tag (engineers approving the proposal means they confirm).
   - Preserve every `[NEW]` tag (so engineers know which values are introduced for the first time).
   - Strip the open-questions checklist section.
   - Strip the "Out of scope" section (already addressed in proposed-events.md; not needed here).
5. Add a header:
   ```markdown
   # Final event map — <project-name>

   Finalized: <YYYY-MM-DD>
   Approved by: see APPROVED file (run `cat projects/<project>/APPROVED` for any signature)
   ```
6. Write `projects/<project>/final-event-map.md`.

## Output

- `projects/<project>/final-event-map.md`

## Constraints

- Never modify `proposed-events.md`.
- Never delete the `APPROVED` marker.
- Never write outside `projects/<project>/`.

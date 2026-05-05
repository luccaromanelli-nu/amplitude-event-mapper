# Event proposal — <project_name>

**Project:** <project_name>
**Country:** <country>
**Experiment:** <expr_id> (cells: <cells>) | <or "feature launch — no A/B">
**Scope:** <scope>

**Generated:** <YYYY-MM-DD>
**Status:** Pending engineer review

---

## Summary

<2-3 sentence summary of what is being proposed. Mention number of new events, number of reused events with new property values, number of [CONFIRM] items.>

---

## Out of scope

<What is intentionally not covered. Prevents engineers from asking "what about X?" when X was considered and excluded.>

- <bullet>
- <bullet>

---

## Proposed events

<For each event, render either a single block or a comparison table.>

<Single block format — when the event has the same shape across cells, or there are no cells:>

### Event: `<event_name>` — <short description>

**Trigger:** <when fires>
**Rationale:** <one line — business question>

| Property | Value |
|----------|-------|
| current_screen | `<value>` `[NEW]` |
| entity_name | `<value>` |
| expr_id | `<value>` |
| owner | `<value>` |
| provider | `<value>` |
| variant | `<cell>` |

**Source(s):** <links>

---

<Comparison table format — when cells share the event but differ in property values:>

### Event: `<event_name>` — <short description>

**Trigger:** <when fires>
**Rationale:** <one line — business question>

| Property | control | soft | hard |
|----------|---------|------|------|
| current_screen | `<value>` | `<value>` `[NEW]` | `<value>` `[NEW]` |
| entity_name | `<value>` | `<value>` | `<value>` |
| expr_id | `<value>` `[CONFIRM]` | `<value>` `[CONFIRM]` | `<value>` `[CONFIRM]` |
| owner | `<value>` | `<value>` | `<value>` |
| provider | `<value>` | `<value>` | `<value>` |
| variant | `control` | `soft` | `hard` |

**Source(s):** <links>

---

## Open questions (engineer sign-off checklist)

Resolve each item before approving. Tick by replacing `[ ]` with `[x]` inline; the finalize step strips this section.

- [ ] 1. `[CONFIRM]` `<event>.<property>` value `<value>` — <reason this needs confirmation>
- [ ] 2. `[NEEDS-HUMAN]` `<event>` — <decision needed>
- [ ] ...

---

## Approval

When every item above is ticked:

```bash
touch projects/<project>/APPROVED
```

Then re-run `/amplitude-event-mapper:propose <project>` (or `/amplitude-event-mapper:finalize <project>`) to promote this file to `final-event-map.md`.

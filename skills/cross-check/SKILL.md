---
description: Build the gap matrix between Figma screens, Miro/Confluence documentation, and live Amplitude firings. Identifies stale, undocumented, and mismatched events.
---

# Cross-check

You build the gap matrix between four data sources: Figma screen inventory, Miro documentation, Confluence documentation, and live Amplitude firings.

## Inputs

- `projects/<project>/existing-events.md` — produced by gather agents
- `projects/<project>/source-docs.md` — Figma screen inventory

## Behavior

1. Build three sets:
   - **D** = events documented in Miro ∪ Confluence
   - **F** = events firing in Amplitude (production, last 30 days)
   - **S** = screens / interactions in Figma

2. Compute three gaps:
   - **Stale or broken** = D ∖ F (documented but not firing)
   - **Undocumented** = F ∖ D (firing but not documented)
   - **Property mismatches** = events in D ∩ F where a property value differs across sources

3. Compute Figma coverage:
   - **Uncovered Figma nodes** = nodes in S with no matching event in D ∪ F
   - For A/B tests, additionally compute per-cell coverage: each Figma cell × each event must have a `variant` property.

## Output

Write `projects/<project>/cross-check.md` using `templates/cross-check-template.md`:

```markdown
# Cross-check — <project>

## Stale or broken (documented but not firing)

| Event | Properties | Source | Last seen firing | Notes |
|-------|------------|--------|-------------------|-------|
| ... |

## Undocumented (firing but not documented)

| Event | Properties | Firings (30d) | Action |
|-------|------------|---------------|--------|
| ... |

## Property mismatches

| Event | Property | Documented value | Firing value | Source of doc |
|-------|----------|-------------------|--------------|----------------|
| ... |

## Uncovered Figma nodes

| Cell | Screen | Node | Type | Notes |
|------|--------|------|------|-------|
| ... |

## A/B coverage gap (per-cell)

| Event | Cells covered | Cells missing | Action |
|-------|---------------|---------------|--------|
| ... |
```

## Constraints

- Pure analysis — no MCP calls, no Bash. Read input files, write one output file.
- If a section is empty, write the table header followed by `_(none)_` so reviewers can see the section was checked.

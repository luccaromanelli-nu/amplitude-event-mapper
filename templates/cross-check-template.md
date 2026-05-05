# Cross-check — <project_name>

**Generated:** <YYYY-MM-DD>

This is the gap matrix between Figma screens (S), Miro/Confluence documentation (D), and live Amplitude firings (F).

---

## Stale or broken (documented but not firing)

Events present in D but absent from F.

| Event | Properties | Source | Last seen firing | Notes |
|-------|------------|--------|-------------------|-------|

_(none)_ when empty.

---

## Undocumented (firing but not documented)

Events present in F but absent from D.

| Event | Properties | Firings (30d) | Action |
|-------|------------|---------------|--------|

_(none)_ when empty.

---

## Property mismatches

Events in D ∩ F where a property value differs across sources.

| Event | Property | Documented value | Firing value | Source of doc |
|-------|----------|-------------------|--------------|----------------|

_(none)_ when empty.

---

## Uncovered Figma nodes

Nodes in S with no event in D ∪ F.

| Cell | Screen | Node | Type | Notes |
|------|--------|------|------|-------|

_(none)_ when empty.

---

## A/B coverage gap

Events not defined for every cell.

| Event | Cells covered | Cells missing | Action |
|-------|---------------|---------------|--------|

_(none)_ when empty or non-A/B project.

---

## Summary

- Stale or broken: <count>
- Undocumented: <count>
- Mismatches: <count>
- Uncovered Figma nodes: <count>
- A/B coverage gaps: <count>

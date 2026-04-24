# Change-037 — Project detail data wiring

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI/DB
- Related Skills: project-review, tags
- Related ADRs:
- Status: Done

## What changed
- Project list now pulls from project tags in CoreData and shows usage counts.
- Project detail timeline now lists tagged atoms; tapping opens Atom detail.
- Project review tab now derives a lightweight narrative and shows key fragments from tagged atoms.

## Files touched
- `Life Narattor/Life Narattor/Screens/ProjectsListScreen.swift`
- `Life Narattor/Life Narattor/Screens/ProjectDetailScreen.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Projects list reflects actual project tags instead of placeholders.
- Project detail timeline and review show data from tagged atoms.

## Verification steps
1) Create a project tag and assign it to at least one atom.
2) Open Project tab and verify the project appears with a count.
3) Open Project detail → 时间线 shows tagged atoms; tap one opens Atom detail.
4) Open Project detail → 回顾 shows a short narrative derived from tagged atoms.

## Rollback plan
- Revert files listed above.

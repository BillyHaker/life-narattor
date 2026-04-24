# Change-038 — Project review structure blocks & sources

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI
- Related Skills: project-review
- Related ADRs:
- Status: Done

## What changed
- Project review now shows structure blocks (timeline/turning points/blockers/next steps) derived from tagged atoms.
- Added a collapsible “引用来源” section that maps narrative sentences to atom sources.
- Source rows open Atom detail.

## Files touched
- `Life Narattor/Life Narattor/Screens/ProjectDetailScreen.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Project review reads more like a structured review and provides traceable sources.

## Verification steps
1) Open a Project detail with tagged atoms.
2) Switch to 回顾.
3) Verify structure blocks show items derived from atoms (or "暂无").
4) Expand “引用来源” and tap a row to open Atom detail.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/Screens/ProjectDetailScreen.swift`.

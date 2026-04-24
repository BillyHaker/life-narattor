# Change-035 — Review by tag picker

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI
- Related Skills: review-memory, tags, search
- Related ADRs:
- Status: Done

## What changed
- Added a Review tag picker screen for project/theme and wired ReviewHome entry points to it.

## Files touched
- `Life Narattor/Life Narattor/Screens/ReviewByTagPickerScreen.swift`
- `Life Narattor/Life Narattor/Screens/ReviewHomeScreen.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Review tab now allows selecting a project or theme tag and jumps into Search with the filter applied.

## Verification steps
1) Open Review tab.
2) Tap “按项目回顾” or “按主题回顾”.
3) Select a tag and confirm Search opens with that tag filtered.

## Rollback plan
- Revert edits in the files listed above.

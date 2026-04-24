# Change-034 — Day detail sources mapping

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI
- Related Skills: timeline-browse, daily-narrative-two-layer
- Related ADRs:
- Status: Done

## What changed
- Added a collapsible “引用来源” section in Day Detail that maps narrative sentences to capture timestamps and opens the capture detail.

## Files touched
- `Life Narattor/Life Narattor/Screens/DayDetailScreen.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Day detail now has a collapsible sources mapping section instead of a flat list.

## Verification steps
1) Open Timeline tab and select a day card.
2) In Day detail, expand “引用来源”.
3) Tap a source row and confirm it opens the capture detail sheet.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/Screens/DayDetailScreen.swift`.

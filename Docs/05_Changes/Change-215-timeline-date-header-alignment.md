# Change 215 — Timeline date header alignment

## Summary
Added the same `今天 · yyyy/MM/dd` date header to the Timeline page so its top area matches the Record page's visual rhythm.

## Changes
- Added a compact date header above the Timeline range picker.
- Tightened top vertical spacing from 16 to 14.
- Added a Timeline-specific `formattedTodayDate(_:)` helper for the top date.
- Preserved existing day-card date formatting and all Timeline filtering/summary behavior.

## Sizing Decision
The range picker remains the native iOS segmented control size. This keeps touch behavior and platform familiarity stable. Comfort is controlled through consistent 16pt horizontal margins and tighter vertical grouping, rather than custom height overrides that would make the control feel heavier.

## Files Changed
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- `git diff --check` passed.
- Debug build passed after sequential rerun.
- Release build passed.
- `Life NarattorTests` passed.

## Rollback
Revert this change commit to remove the Timeline date header and restore the previous spacing.

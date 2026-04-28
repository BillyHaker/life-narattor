# Change 214 — Unified record and timeline filter headers

## Summary
Removed explanatory text above the Record and Timeline range filters so both pages start with a cleaner, more consistent filter area.

## Changes
- Removed the `回看范围` label above the Record range picker.
- Tightened Record top spacing slightly.
- Removed the Timeline `时间线` title and scope description.
- Moved Timeline range picker to be the first visible page control.
- Kept filtering, search, summaries, and day-card behavior unchanged.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- Static scan confirmed removed labels no longer appear in the relevant screen files.
- `git diff --check` passed.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed.

## Rollback
Revert this change commit to restore the old Record label and Timeline title/description header.

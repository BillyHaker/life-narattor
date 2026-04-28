# Change 217 — Record all scope scrolls to latest

## Summary
The Record page now requests latest-item scrolling when the range filter changes, so switching to `全部` lands near the newest record rather than the oldest.

## Changes
- Added `selectedScope` handling inside `ScrollViewReader`.
- Delayed `scrollTo` until after the filtered list has had time to lay out.
- Kept list sort order and data behavior unchanged.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- `git diff --check` passed.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed.

## Rollback
Revert this change commit to restore the previous scroll behavior.

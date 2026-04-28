# Change 218 — Record all bottom-anchor scroll

## Summary
Replaced the Record page's latest-row scroll target with a stable bottom anchor so switching to `全部` can reliably land near the newest record.

## Changes
- Added an invisible bottom anchor to the record list.
- Changed latest scrolling to `scrollTo(recordListBottomID, anchor: .bottom)`.
- Removed the latest-row UUID lookup.
- Preserved list order and filtering behavior.

## Reason
Manual testing showed that scrolling to the latest row UUID could still leave the list at the oldest record. A bottom anchor is more stable in a lazy, sectioned list because it always exists at the end of the rendered list structure.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- `git diff --check` passed.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed.

## Rollback
Revert this change commit to restore the previous UUID-row scroll behavior.

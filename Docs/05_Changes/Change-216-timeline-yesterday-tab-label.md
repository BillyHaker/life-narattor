# Change 216 — Timeline yesterday tab label

## Summary
Changed the Timeline range picker's first tab label from `今天` to `昨日`.

## Changes
- Updated `TimelineScope.today.title` to return `昨日`.
- Left scope identity and date interval logic unchanged.

## Files Changed
- `Life Narattor/Models/TimelineModels.swift`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- `git diff --check` passed.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed.

## Rollback
Revert this change commit to restore the picker label to `今天`.

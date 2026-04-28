# Change 212 — Dynamic AI Review clue display

## Summary
Made AI Review clue cards adapt their icon, color, and subtitle to the clue name when possible, with safe fallback to existing tag-type styling.

## Changes
- Added a local `ReviewClueDisplay` presentation model.
- Added keyword-based display inference for common user content domains: work, morning routine, sleep, emotion, body/food/exercise, games, learning, and relationships.
- Kept tag-type fallback for labels that do not match the keyword map.
- Updated clue cards to use inferred display metadata.
- Kept clue selection, filtering, time range, and AI Review submission behavior unchanged.

## Files Changed
- `Life Narattor/Screens/SearchScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- `git diff --check` passed.
- Static scan confirmed dynamic clue display code is present.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed on iPhone 17 Pro Max simulator.

## Rollback
Revert this change commit. The change is presentation-only and does not alter persisted tags or retrieval logic.

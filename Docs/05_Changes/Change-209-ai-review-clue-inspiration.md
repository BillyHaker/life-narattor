# Change 209 — AI Review clue inspiration entry

## Summary
Integrated long-term clue entry points into `AI 回顾` and removed the standalone `线索` bottom tab.

## Changes
- Removed the `线索` tab from the root `TabView`.
- Kept existing project/clue list/detail screens available in code, but no longer exposed them as a primary tab.
- Added a `最近线索` section to the empty AI Review home state.
- Shows only user-visible tags that already have related atom material.
- Sorts clue cards by related material count, then recency.
- Clicking a clue automatically starts an AI Review question around that clue with a matching tag filter and recent time range.
- Refined AI Review header copy toward lightweight review/inspiration instead of a separate search-management model.
- Updated App Store submission copy to match the new primary navigation structure.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/SearchScreen.swift`
- `Docs/06_Testing/App-Store-Submission-Copy.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- Static scan found no remaining root `projects` tab or visible bottom `线索` tab declaration.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed on iPhone 17 Pro Max simulator.
- Full scheme test command returned `TEST SUCCEEDED`, with a non-blocking Simulator UI runner launch noise line.

## Rollback
Revert this change commit. The older clue screens were not deleted, so restoring the bottom tab only requires reverting the root navigation and AI Review home-state changes.

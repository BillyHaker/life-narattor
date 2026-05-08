# Change 236 - Timeline Completed Period Alignment

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Timeline/UX
- Status: Done
- Related ADR: Docs/03_Decisions/ADR-018-timeline-completed-periods.md

## Goal
Make Timeline review tabs use one consistent date range between the AI story card and the lower day list.

## Files Changed
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/03_Decisions/ADR-018-timeline-completed-periods.md`
- `Docs/04_Sessions/2026-05-08_session-001.md`
- `Docs/05_Changes/Change-236-timeline-completed-period-alignment.md`

## Implementation
- Updated Timeline list range calculation to use completed periods instead of live current periods.
- `昨日` now fetches yesterday only, not today.
- `7天回顾` and `30天回顾` now end at today's start, so today is excluded.
- Adjusted empty-state copy for the `昨日` tab.
- Hid zero-value snapshot metric pills for empty snapshots.

## User-visible impact
- Timeline no longer shows today's records under the `昨日` tab.
- Snapshot summaries and visible day cards should no longer contradict each other.
- Empty review cards look quieter when there is no material.

## Verification
- `git diff --check` passed.
- Debug simulator build passed.
- Full test command passed, including unit tests and UI launch tests.

## Manual Verification
- Open Timeline.
- Tap `昨日`, `7天回顾`, `30天回顾`.
- Confirm visible day cards match the selected completed period.
- Confirm no-material ranges do not show zero metric pills.

## Rollback
- Revert this commit to restore the previous range calculation and empty snapshot metric display.

---
date: 2026-04-26
owner: Codex
scope: UX/UI/AI
status: Done
related_skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/acceptance-testing-min-bar/SKILL.md
related_decisions:
  - Docs/03_Decisions/ADR-014-timeline-snapshot-summaries.md
---

# Change-203 — Timeline Snapshot Freshness Fix

## What Changed
- Removed the `整理于 ...` status chip from Timeline snapshot summary cards.
- Extended `TimelineReviewSnapshotPayload` with `latestRecordAt` so snapshot validity can reflect data changes, not just date-range changes.
- Updated `TimelineReviewSnapshotService` freshness checks so an existing snapshot is considered stale when any of these change inside the target range:
  - active day count
  - total formal-record count
  - latest formal-record timestamp
- Added a guard so an old empty snapshot is never reused once the range now contains formal records.
- Kept the snapshot refresh model lightweight: snapshots still refresh on open / foreground / scope change, but they now actually notice when new records were added later in the same period.

## Files Touched
- `Life Narattor/Models/ReviewModels.swift`
- `Life Narattor/Data/TimelineReviewSnapshotService.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/04_Sessions/2026-04-26_session-001.md`
- `Docs/05_Changes/Change-203-timeline-snapshot-freshness-fix.md`

## User-Visible Impact
- Timeline snapshot cards no longer show a distracting `整理于 ...` label.
- If a snapshot was generated earlier as empty and the user later added records, Timeline now refreshes that range instead of continuing to show `0 天有记录 / 0 条材料`.
- The summary card stays calm, but it is less likely to look obviously wrong after new captures appear.

## Root Cause
- The phase-1 snapshot service only validated snapshots by comparing `rangeStart` and `rangeEnd`.
- That meant an empty snapshot created earlier in the day could still be treated as current later in the same day, even after new records had been added to the covered range.
- The bug was therefore not primarily in retrieval or AI analysis; it was in snapshot freshness invalidation.

## Detection Plan
- Expected behavior:
  - a stale empty snapshot should be regenerated after new formal records are added in the same covered period
  - the Timeline summary card should no longer display `整理于 ...`
- Detection path:
  - open Timeline and let a range cache an empty snapshot
  - add a new formal record that falls inside that covered range
  - reopen Timeline or background/foreground the app
- Pass criteria:
  - the summary no longer shows `0 天有记录 / 0 条材料` if records now exist in range
  - no `整理于 ...` chip is shown in the summary card
- Failure signals:
  - stale empty snapshot still renders after adding qualifying records
  - summary remains tied only to range dates and ignores later data changes
- Regression surface:
  - Timeline snapshot card
  - ArtifactEntity snapshot persistence
  - Timeline foreground refresh behavior

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`

## Rollback Notes
- Revert `TimelineReviewSnapshotService.swift` to the earlier range-only staleness check if the new freshness checks cause undesired refresh churn.
- Revert the `latestRecordAt` field in `ReviewModels.swift` if the snapshot payload shape needs to be simplified again.
- Revert the `TimelineScreen.swift` UI change to restore the `整理于 ...` chip if product direction changes later.

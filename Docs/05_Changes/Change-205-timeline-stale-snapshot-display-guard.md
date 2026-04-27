---
date: 2026-04-26
owner: Codex
scope: UX/AI
status: Done
related_skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/acceptance-testing-min-bar/SKILL.md
related_decisions:
  - Docs/03_Decisions/ADR-014-timeline-snapshot-summaries.md
---

# Change-205 — Timeline Stale Snapshot Display Guard

## What Changed
- Exposed `TimelineReviewSnapshotService.isSnapshotCurrent(_:)` so Timeline can validate cached snapshots before display.
- Updated `TimelineScreen` to hide stale cached snapshots instead of rendering them as current summary cards.
- Changed snapshot refresh ordering so the currently selected scope refreshes first.
- Updated refresh behavior so each snapshot updates the UI as soon as it finishes, instead of waiting for all snapshot kinds.

## Files Touched
- `Life Narattor/Data/TimelineReviewSnapshotService.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/04_Sessions/2026-04-26_session-001.md`
- `Docs/05_Changes/Change-205-timeline-stale-snapshot-display-guard.md`

## User-Visible Impact
- Timeline should no longer briefly show known-stale empty summaries such as `0 天有记录 / 0 条材料` when the covered period already has records.
- If a cached snapshot is stale, the summary card enters a refresh/fallback state until the updated snapshot is ready.
- The selected tab, such as `本周`, receives refreshed summary content before unrelated snapshot windows.

## Detection Plan
- Expected behavior:
  - stale snapshots are not displayed as final facts
  - selected Timeline scope refreshes first
  - UI updates after each snapshot refresh
- Detection path:
  - open Timeline with an old empty cached snapshot
  - select `本周`
  - watch the summary card while refresh runs
- Pass criteria:
  - stale `0 天 / 0 条` content does not render if freshness says records exist
  - refreshed `last7Days` content appears without waiting for `yesterday` and `last30Days`
- Failure signals:
  - stale cached summary appears as a normal result
  - current tab stays stale until all snapshot kinds finish refreshing
- Regression surface:
  - Timeline summary card loading state
  - snapshot refresh lifecycle
  - app foreground refresh

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`

## Rollback Notes
- Revert `TimelineScreen.refreshSnapshotsIfNeeded(prioritizedKind:)` to the previous all-at-once refresh if incremental UI updates cause unexpected flicker.
- Revert `TimelineReviewSnapshotService.isSnapshotCurrent(_:)` if cached snapshot display should become unconditional again.
- No data migration is involved.

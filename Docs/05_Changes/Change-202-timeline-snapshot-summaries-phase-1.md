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

# Change-202 — Timeline Snapshot Summaries Phase 1

## What Changed
- Added `TimelineReviewSnapshotKind` and `TimelineReviewSnapshotPayload` to represent persisted storyline summaries for:
  - yesterday
  - past 7 days
  - past 30 days
- Added `TimelineReviewSnapshotService` that:
  - loads snapshot artifacts from `ArtifactEntity`
  - checks whether a snapshot is stale by comparing stored date range to the current desired range
  - regenerates snapshot summaries from `ReviewRetrievalService` and AI analysis when needed
  - writes fallback summaries when AI is unavailable or the period is empty
- Updated `TimelineScreen` so the summary card now reads from snapshots first.
- Changed Timeline summary semantics:
  - `今天` tab shows `昨日故事线`
  - `本周` shows `过去 7 天故事线`
  - `本月` and `近30天` show `过去 30 天故事线`
- Added foreground/on-open refresh so snapshots can update daily without requiring exact iOS background execution guarantees.

## Files Touched
- `Life Narattor/Models/ReviewModels.swift`
- `Life Narattor/Data/TimelineReviewSnapshotService.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/03_Decisions/ADR-014-timeline-snapshot-summaries.md`
- `Docs/04_Sessions/2026-04-26_session-001.md`
- `Docs/05_Changes/Change-202-timeline-snapshot-summaries-phase-1.md`

## User-Visible Impact
- Timeline summary cards no longer feel like realtime explanatory blurbs.
- The page keeps live day browsing while showing a more stable storyline reference from a completed period.
- Users can get guidance without expecting Timeline to update its “storyline” after every new capture.

## Detection Plan
- Expected behavior:
  - snapshot labels appear in Timeline summary cards
  - summary content comes from persisted or regenerated completed-period snapshots
  - Timeline still shows live day nodes beneath the snapshot summary
- Detection path:
  - build the app
  - run unit tests
  - open Timeline and switch scopes
  - background/foreground the app and reopen Timeline
- Pass criteria:
  - build/tests pass
  - snapshot labels are visible
  - summary card shows stable storyline copy instead of count-only blurbs when snapshots exist
- Failure signals:
  - snapshot service never persists or reloads values
  - UI blocks on refresh or shows empty summary unnecessarily
  - Timeline nodes disappear or become coupled to snapshot generation
- Regression surface:
  - Timeline summary card
  - app foreground lifecycle
  - review retrieval-based summary generation
  - artifact JSON persistence

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`
- `rg -n "昨日故事线|过去 7 天故事线|过去 30 天故事线|TimelineReviewSnapshotService|timeline_review_snapshot_v1" 'Life Narattor'`

## Rollback Notes
- Revert `TimelineReviewSnapshotService.swift` and the Timeline summary-card integration to restore the previous realtime summary text behavior.
- Revert the new snapshot types in `ReviewModels.swift` if the snapshot layer is abandoned.
- No schema migration is required because snapshots are stored as ordinary `ArtifactEntity` JSON payloads.

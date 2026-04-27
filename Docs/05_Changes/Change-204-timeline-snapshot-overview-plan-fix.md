---
date: 2026-04-26
owner: Codex
scope: AI/UX
status: Done
related_skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/acceptance-testing-min-bar/SKILL.md
related_decisions:
  - Docs/03_Decisions/ADR-014-timeline-snapshot-summaries.md
---

# Change-204 — Timeline Snapshot Overview Plan Fix

## What Changed
- Added `RetrievalPlanBuilder.makeSystemOverviewPlan(periodLabel:range:)` for system-generated range summaries.
- Updated programmatic open review planning so fixed windows like `过去 7 天` and `过去 30 天` always use `mode == .overview`.
- Kept ordinary user natural-language retrieval on the existing `build(query:)` path.
- Updated Timeline snapshot fallback payloads so failed summary generation still reports the real active-day and formal-record counts.
- Added `RetrievalPlanBuilderTests` to lock the behavior that spaced day labels do not get misclassified as focused/comparison retrieval.

## Files Touched
- `Life Narattor/Data/RetrievalPlanBuilder.swift`
- `Life Narattor/Data/TimelineReviewSnapshotService.swift`
- `Life NarattorTests/RetrievalPlanBuilderTests.swift`
- `Docs/04_Sessions/2026-04-26_session-001.md`
- `Docs/05_Changes/Change-204-timeline-snapshot-overview-plan-fix.md`

## User-Visible Impact
- Timeline snapshot cards should no longer claim `0 天有记录 / 0 条材料` when the period actually contains formal records.
- `过去 7 天故事线` and `过去 30 天故事线` now use a stable system overview path instead of depending on natural-language query inference.
- If summary generation still cannot produce a storyline, the card should remain factually honest about the records it can see.

## Root Cause
- System-generated Timeline snapshots reused the same natural-language retrieval planning path as user questions.
- The generated query for `过去 7 天` included a spaced numeric time label and the word `变化`.
- The query parser did not recognize `过去 7 天` as a broad review window and could infer a focused/comparison query instead.
- Focused plans with no matching filters excluded otherwise valid records, so `makeRangeReviewData` returned nil.

## Detection Plan
- Expected behavior:
  - programmatic range review plans are always overview plans
  - Timeline snapshot fallback stats reflect actual formal records even if summary generation fails
- Detection path:
  - run the new `RetrievalPlanBuilderTests`
  - build the app
  - open Timeline and switch to `本周` / `本月`
- Pass criteria:
  - `makeOpenReviewPlan(periodLabel: "过去 30 天", ...)` returns `mode == .overview`
  - the summary card no longer shows zero stats for a range that has formal records
- Failure signals:
  - `过去 7 天` is still classified through natural-language focused retrieval
  - Timeline card reports zero records while the day cards below show records
- Regression surface:
  - Timeline snapshot summary generation
  - Weekly/monthly range review retrieval
  - Ordinary AI search retrieval planning

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`

## Rollback Notes
- Revert `RetrievalPlanBuilder.swift` and `RetrievalPlanBuilderTests.swift` to send programmatic open reviews back through natural-language planning.
- Keep the truthful fallback stats in `TimelineReviewSnapshotService.swift` if only the system overview plan needs to be reverted.
- No schema migration is involved.

---
date: 2026-04-25
owner: Codex
scope: UX/UI/AI
status: Done
related_skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/acceptance-testing-min-bar/SKILL.md
related_decisions:
  - Docs/03_Decisions/ADR-013-range-review-primary-surface.md
---

# Change-201 — Weekly/Monthly Range Review Redesign

## What Changed
- Reworked `WeeklyReviewScreen` and `MonthlyReviewScreen` so they now behave like range-level review pages instead of date-list pages.
- Added shared range-review view data inside `ReviewRetrievalService`:
  - `RangeReviewData`
  - `RangeReviewSection`
  - `RangeReviewEvidenceGroup`
- Weekly/monthly pages now render in this order:
  - overall summary
  - structural sections (themes / changes / patterns / turning points)
  - evidence groups
  - follow-up prompts
  - source dates last
- Changed the time semantics:
  - `本周` now uses the current calendar week
  - `本月` now uses the current calendar month
- Kept traceability by preserving navigation into `DayDetailScreen`, but moved it into the final `来源日期` section.

## Files Touched
- `Life Narattor/Data/ReviewRetrievalService.swift`
- `Life Narattor/Screens/WeeklyReviewScreen.swift`
- `Life Narattor/Screens/MonthlyReviewScreen.swift`
- `Docs/03_Decisions/ADR-013-range-review-primary-surface.md`
- `Docs/04_Sessions/2026-04-25_session-001.md`
- `Docs/05_Changes/Change-201-weekly-monthly-range-review-redesign.md`

## User-Visible Impact
- Weekly/monthly review now reads like “what happened during this whole period” instead of “here are some days you can tap”.
- The most important information is now the period summary and its supporting structure, not day cards.
- Users can still trace a claim back to source days, but that no longer dominates the page.

## Detection Plan
- Expected behavior:
  - `本周` and `本月` open as whole-period review pages
  - day navigation appears as supporting traceability, not the main layout
  - current week/month semantics replace rolling 7/30 day windows
- Detection path:
  - build the app
  - run unit tests
  - open `AI回顾` → `本周`
  - open `AI回顾` → `本月`
- Pass criteria:
  - first screenful shows whole-period summary and structural signals
  - no `本周片段` / `本月片段` section remains
  - source-day links are present only in the supporting traceability area
- Failure signals:
  - page still feels like a date list
  - week/month scope still behaves like rolling 7/30 days
  - no path remains to inspect supporting source days
- Regression surface:
  - weekly review
  - monthly review
  - review retrieval summaries
  - day-detail navigation from source links

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`
- `rg -n "本周片段|本月片段|最近7天|最近30天" 'Life Narattor/Screens/WeeklyReviewScreen.swift' 'Life Narattor/Screens/MonthlyReviewScreen.swift' 'Life Narattor/Data/ReviewRetrievalService.swift'`

## Rollback Notes
- Revert `WeeklyReviewScreen.swift` and `MonthlyReviewScreen.swift` to restore the previous day-list-first review UI.
- Revert the new range-review helpers in `ReviewRetrievalService.swift` if the shared view-data layer is not desired.
- Revert ADR-013 and this change log if product direction changes.

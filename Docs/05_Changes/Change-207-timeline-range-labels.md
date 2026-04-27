---
date: 2026-04-27
owner: Codex
scope: UX/Timeline
status: Done
related_skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/acceptance-testing-min-bar/SKILL.md
related_decisions:
  - Docs/03_Decisions/ADR-014-timeline-snapshot-summaries.md
---

# Change-207 — Timeline Range Labels

## What Changed
- Changed Timeline visible tabs from `本周 / 本月` to `7天回顾 / 30天回顾`.
- Limited the visible segmented control to `今天 / 7天回顾 / 30天回顾` to avoid duplicate 30-day concepts.
- Updated Timeline header and empty-state text to remove natural week/month wording.
- Changed `.week` list retrieval from natural calendar week to the previous 7 days.
- Changed `.month` list retrieval from natural calendar month to the previous 30 days.

## Files Touched
- `Life Narattor/Models/TimelineModels.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/04_Sessions/2026-04-27_session-001.md`
- `Docs/05_Changes/Change-207-timeline-range-labels.md`

## User-Visible Impact
- Timeline now says what it actually means: rolling review windows rather than natural calendar periods.
- Users should no longer expect `本周` to mean Monday-to-today or `本月` to mean month-to-date.
- The screen is simpler because the duplicated `近30天` tab is no longer visible.

## Detection Plan
- Expected behavior:
  - tabs read `今天 / 7天回顾 / 30天回顾`
  - `本周 / 本月` do not appear in Timeline screen copy
  - `7天回顾` includes records from the recent 7-day interval
  - `30天回顾` includes records from the recent 30-day interval
- Detection path:
  - run `rg -n "本周|本月" Life\ Narattor/Screens/TimelineScreen.swift Life\ Narattor/Models/TimelineModels.swift`
  - run build and tests
  - manually open Timeline and switch tabs
- Pass criteria:
  - no Timeline copy uses natural week/month labels
  - build and tests pass
  - visible segmented control has no duplicated 30-day tab
- Failure signals:
  - UI still shows `本周` or `本月`
  - list data and summary data cover different period semantics
  - a hidden `.custom` state becomes user-selectable unexpectedly

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`

## Rollback Notes
- Restore `TimelineScope.title` for `.week/.month` if natural period labels are desired again.
- Restore `TimelineScope.allCases` in the picker if `近30天` needs to be visible again.
- Restore `calendar.dateInterval(of: .weekOfYear/.month, for:)` if the list should return to natural week/month windows.
- No data migration is involved.

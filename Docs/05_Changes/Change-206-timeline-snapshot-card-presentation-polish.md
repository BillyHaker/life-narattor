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

# Change-206 — Timeline Snapshot Card Presentation Polish

## What Changed
- Added a lightweight Timeline snapshot display model that converts stored AI summary text into user-facing fields.
- Updated the range story card to show a concise main story line plus an optional `可能的联系` section.
- Suppressed `可继续问` content from the Timeline range card so the card stays focused on review, not chat prompts.
- Limited displayed summary lengths and normalized whitespace to avoid dense report-like blocks.
- Muted overview signal chips so they behave as context markers instead of primary actions.

## Files Touched
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/04_Sessions/2026-04-26_session-001.md`
- `Docs/05_Changes/Change-206-timeline-snapshot-card-presentation-polish.md`

## User-Visible Impact
- Timeline summaries should feel calmer and easier to scan.
- The first story card should no longer expose raw AI labels such as `事实：`、`联系：`、`可继续问：`.
- Tags/signals remain available but with lower visual priority.

## Detection Plan
- Expected behavior:
  - raw AI report labels are not shown in the card
  - the card has a short main summary and optional secondary relationship note
  - chips are visually quieter than the summary text
- Detection path:
  - open Timeline `本周` or `本月` after a snapshot has been generated
  - inspect the first summary card
- Pass criteria:
  - summary is readable without scrolling through a report block
  - `可继续问` is absent from the Timeline card
  - build and unit tests pass
- Failure signals:
  - raw markdown or section labels leak into UI
  - summary text is too long for a quick Timeline scan
  - muted chips are mistaken for primary controls
- Regression surface:
  - Timeline range story summary card
  - snapshot fallback display
  - AI summary parsing for future prompt variants

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`

## Rollback Notes
- Revert the summary parsing helpers and restore direct rendering of `snapshot.summaryText` in `TimelineScreen.rangeSummaryView`.
- No data migration is involved; existing snapshots remain compatible.

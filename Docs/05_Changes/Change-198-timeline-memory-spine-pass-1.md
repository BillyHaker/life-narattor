---
date: 2026-04-25
owner: Codex
scope: UX/UI
status: Done
related_skills:
  - Skills/product-northstar/SKILL.md
  - Skills/timeline-browse/SKILL.md
  - Skills/acceptance-testing-min-bar/SKILL.md
---

# Change-198 — Timeline Memory Spine Pass 1

## What Changed
- Reworked the Timeline day-card model so it describes a readable day summary instead of a raw `highlights + hasNarrative` pair.
- Rebuilt Timeline home around `时间线` as a memory surface: title, scope guidance, range summary card, softer empty states, and calmer day cards.
- Replaced action-heavy timeline entry language with date-based review language such as `回看这一天`.
- Removed fake narrative-state inference that treated `>= 3` records as an existing day narrative.
- Synced Timeline day construction in retrieval-based builders and search grouping.
- Updated weekly/monthly preview cards to render the new day summary line.
- Replaced one remaining Day Detail engineering phrase (`结构化片段`) with user-facing language.
- Follow-up adjustment: when a day has no AI-ready material, the `AI 轻回应` module is now hidden entirely instead of explaining system insufficiency to the user.

## Files Touched
- `Life Narattor/Models/TimelineModels.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Life Narattor/Data/ReviewRetrievalService.swift`
- `Life Narattor/Screens/SearchScreen.swift`
- `Life Narattor/Screens/WeeklyReviewScreen.swift`
- `Life Narattor/Screens/MonthlyReviewScreen.swift`
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Docs/04_Sessions/2026-04-25_session-001.md`
- `Docs/05_Changes/Change-198-timeline-memory-spine-pass-1.md`

## User-Visible Impact
Timeline should now read as a calm memory browser: each date shows what kind of day it was, how many pieces were left behind, and invites the user to revisit the day instead of asking them to generate a diary. On day detail, users no longer see a system-flavored message when AI material is absent.

## Detection Plan
- Expected behavior: Timeline cards feel like memory playback, and no screen claims a narrative exists just because there are enough records.
- Detection path: copy scan, build, test, inspect card data flow in Timeline/Search/Retrieval builders.
- Pass criteria: successful build/test, no old timeline generation phrases remain, and weekly/monthly previews still navigate to day detail with the new summary model.
- Failure signals: compile breaks after model migration, day cards missing content, stale copy, or broken search/review navigation to `DayDetailScreen`.
- Regression surface: timeline browsing, weekly/monthly previews, search result day groups, retrieval-generated highlight days.

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' test`
- `rg -n "生成日记|生成当天叙事|整理成今日叙事|查看今日叙事|结构化片段|可用于 AI 回应" 'Life Narattor/Screens' 'Life Narattor/Data' 'Life Narattor/Models'`

## Diagnostic Notes
- The missing AI response state is not caused by the analysis model itself. `DayDetailScreen` only requests AI when `NarrativeMaterial.representativeUnits` is non-empty.
- Those units come from `MemoryIndexStore`, which reads `atomization_payload.recordUnits`. If a capture has not produced split units yet, the screen can still render a fallback day narrative from local records, but it has no AI-ready material to send.

## Rollback Notes
Revert this change set to restore the previous Timeline card model and UI. No schema migration or persisted data rewrite is involved.

---
date: 2026-04-24
owner: Codex
scope: UX/UI
status: Done
related_skills:
  - Skills/product-northstar/SKILL.md
  - Skills/capture-ui/SKILL.md
  - Skills/timeline-browse/SKILL.md
  - Skills/review-memory/SKILL.md
  - Skills/project-review/SKILL.md
  - Skills/acceptance-testing-min-bar/SKILL.md
---

# Change-197 — AI-Native Memory UX Pass

## What Changed
- Shifted Record, Timeline, AI Review, and Project surfaces toward a lightweight memory-container model.
- Renamed the bottom `项目` tab to `线索` while preserving the existing data model.
- Updated Record page copy to emphasize low-pressure capture: `随手记一句就好`, `已接住`, `已整理成 X 个片段`.
- Updated AI Review copy from analysis/search language toward review and traceable evidence: `回看`, `事实与联系`, `线索`.
- Updated Timeline day cards from `生成当天叙事` to `整理成今日叙事` / `查看今日叙事`.
- Updated project/list/detail surfaces to read as long-running lines rather than empty project folders.
- Updated voice transcription completed status from `记录成功` to `已接住`.

## Files Touched
- `Life Narattor/ContentView.swift`
- `Life Narattor/Models/VoiceModels.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Screens/SearchScreen.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Life Narattor/Screens/ProjectsListScreen.swift`
- `Life Narattor/Screens/ProjectDetailScreen.swift`
- `Life Narattor/Screens/ReviewHomeScreen.swift`
- `Life Narattor/Screens/ReviewByTagPickerScreen.swift`
- `Life Narattor/Screens/WeeklyReviewScreen.swift`
- `Life Narattor/Screens/MonthlyReviewScreen.swift`
- `Life Narattor/Views/CaptureCardView.swift`
- `Docs/03_Decisions/ADR-012-ai-native-memory-ux-language.md`
- `Docs/04_Sessions/2026-04-24_session-003.md`
- `Docs/05_Changes/Change-197-ai-native-memory-ux-pass.md`

## User-Visible Impact
The app should feel less like record management plus AI search, and more like a low-pressure place to drop fragments that quietly become reviewable memory lines.

## Detection Plan
- Expected behavior: first screens use record/review/line language instead of heavy generate/search/manage language.
- Detection path: text scan, simulator build, test run, simulator screenshot inspection.
- Pass criteria: build and tests pass; old high-pressure labels no longer appear in primary screens; Record screenshot shows `已接住` and bottom tab `线索`.
- Failure signals: build/test failures, broken navigation, or old labels still dominating first screens.
- Regression surface: record input, voice capture status, AI review search/retrieval, timeline day navigation, project detail navigation.

## Verification Steps
- `rg -n "生成当天叙事|生成日记|标签组|暂无关联记录|搜索记录内容、转写或回应|项目时间线|项目叙事|项目片段|生成项目回顾|直接问一个回顾问题|AI 正在整理|AI 分析|AI 的回应|今天还没有记录，先记一条再来生成叙事|已记录|记录成功" 'Life Narattor/Screens' 'Life Narattor/Views' 'Life Narattor/ContentView.swift' 'Life Narattor/Models' || true`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' test`
- Installed and launched on iPhone 17 Pro Max simulator; screenshot inspection confirmed `已接住` and `线索` are visible.

## Rollback Notes
Revert this commit to return to previous UI wording. No schema or persistence migration is involved.

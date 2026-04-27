---
date: 2026-04-25
owner: Codex
scope: AI/UI/Infra
status: Done
related_skills:
  - Skills/acceptance-testing-min-bar/SKILL.md
---

# Change-199 — Review Material Qualification And Diagnostics

## What Changed
- Added a shared helper (`CaptureReviewSupport`) that resolves input mode, processing state, formal-record eligibility, and whether a capture should be auto-atomized.
- Tightened `TimelineScreen`, `DayDetailScreen`, and `MemoryIndexStore` so only formal `log` records participate in time-based review surfaces and AI retrieval.
- Expanded automatic atomization pickup so formal records stuck in `.cleanReady` are promoted back to `.pendingSplit` and re-enter the split queue.
- Added a DevTools screen (`Review Material Debug`) that shows, per day and per capture:
  - mode
  - input type
  - processing state
  - atoms count
  - whether `atomization_payload` exists
  - how many `recordUnits` are available
  - whether the capture is formal/review-eligible
  - whether it is hidden from the record feed
  - whether it is currently repairable
- Added a lightweight Dev repair action that resets stuck formal records to `pendingSplit` and notifies `CaptureFeedViewModel` to reschedule atomization.
- Removed the disabled `编辑叙事` button from `DayDetailScreen`, since it advertised an action that was not actually available.

## Files Touched
- `Life Narattor/Data/CaptureReviewSupport.swift`
- `Life Narattor/Data/MemoryIndexStore.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/DevTools/DevToolsReviewMaterialView.swift`
- `Life Narattor/DevTools/DevToolsRootView.swift`
- `Docs/04_Sessions/2026-04-25_session-001.md`
- `Docs/05_Changes/Change-199-review-material-pipeline-diagnostics.md`

## User-Visible Impact
- Timeline and Day Detail now ignore assist-session intermediate captures, so date-based review surfaces are closer to “正式记录” instead of mixed pipeline state.
- Records that were formal but stuck in `cleanReady` can now be picked up automatically for拆分, reducing the chance that a day has visible records but no AI-ready material.
- Dev can now inspect exactly why a given day has no AI review material without exposing system-state explanations to end users.

## Detection Plan
- Expected behavior:
  - Assist-session intermediate captures no longer count as time-based review records.
  - Formal `log` captures with clean text and no atoms can be re-queued from `.cleanReady`.
  - DevTools can show which captures have payload-backed review material and which do not.
- Detection path:
  - Build the app.
  - Run unit tests.
  - Open DevTools → `Review Material Debug`.
  - Pick a day with known records and inspect summary counts plus per-capture payload/unit status.
- Pass criteria:
  - Build and tests succeed.
  - DevTools shows a day summary and per-capture status rows.
  - Review retrieval code paths all use the shared helper.
- Failure signals:
  - Timeline or Day Detail still surfaces assist captures.
  - Formal records in `.cleanReady` never re-enter split.
  - DevTools shows no payload/unit info for days that clearly have split material.
- Regression surface:
  - Timeline day grouping
  - Day Detail records and AI response gating
  - Auto atomization queue
  - Dev tab navigation

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`
- `rg -n "capturePendingAtomizationRequested|isEligibleForReviewTimeline|shouldAutoAtomizeForFormalRecord|resolvedReviewProcessingState|Review Material Debug|回顾材料诊断" 'Life Narattor'`

## Rollback Notes
- Revert `CaptureReviewSupport` and the helper call sites to restore the previous, broader capture eligibility behavior.
- Revert `DevToolsReviewMaterialView` and its `DevToolsRootView` navigation link if the diagnostic UI is not desired.
- No schema migration or persistent data rewrite is involved.

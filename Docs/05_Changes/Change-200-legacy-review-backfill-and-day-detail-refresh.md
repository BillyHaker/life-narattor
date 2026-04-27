---
date: 2026-04-25
owner: Codex
scope: AI/UI/Data
status: Done
related_skills:
  - Skills/acceptance-testing-min-bar/SKILL.md
  - Skills/timeline-browse/SKILL.md
---

# Change-200 — Legacy Review Backfill And Day Detail Refresh

## What Changed
- Added `ReviewMaterialRepairService` to repair historical formal records created through the legacy assist-archive path.
- The repair service derives a synthetic `atomization_payload` from stored `AssistArchivePayload` data, so old records with atoms but no payload can once again provide `recordUnits` to day-level AI review.
- Wired passive backfill into `MemoryIndexStore` retrieval, so loading a day can automatically repair eligible old records without a separate migration.
- Wired the legacy `saveAssistArchive` path to backfill payloads immediately after archive atoms/tags are created, reducing the chance of new “atoms but no review material” records.
- Extended `Review Material Debug` with:
  - visibility into whether a capture has `assist_archive_card`
  - a summary count for legacy records missing payload
  - a manual “回填这一天的旧 assist 回顾材料” action
- Refreshed `DayDetailScreen` into a quieter reading hierarchy:
  - `这一天`
  - `当天脉络`
  - `原始片段`
  - optional `AI 轻回应`
  - `叙事引用来源`
- Turned original record rows into calmer source cards that open capture detail on tap, so the page reads more like a day review and less like a feature stack.

## Files Touched
- `Life Narattor/Data/ReviewMaterialRepairService.swift`
- `Life Narattor/Data/MemoryIndexStore.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/DevTools/DevToolsReviewMaterialView.swift`
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Docs/04_Sessions/2026-04-25_session-001.md`
- `Docs/05_Changes/Change-200-legacy-review-backfill-and-day-detail-refresh.md`

## User-Visible Impact
- Older records that were saved via the legacy assist-archive flow can now re-enter day-level AI review once payload backfill runs.
- Dev now has a direct way to repair a specific day’s legacy assist review materials instead of guessing why AI review is empty.
- Day Detail now emphasizes reading the day first and AI second, which fits the product goal of low-pressure review.

## Detection Plan
- Expected behavior:
  - legacy formal records with `assist_archive_card` but no `atomization_payload` can be backfilled
  - `Review Material Debug` surfaces the missing-payload count and can trigger a repair
  - Day Detail reads as a calm review page with facts first, AI later
- Detection path:
  - Build the app
  - Run unit tests
  - Open `Dev` → `Review Material Debug` → choose a day with older assist-saved records
  - Trigger `回填这一天的旧 assist 回顾材料` if available
  - Open `时间线` → choose a day → inspect the new section order in Day Detail
- Pass criteria:
  - build/tests pass
  - DevTools shows legacy assist payload status
  - backfill action completes without error
  - Day Detail shows the new section stack and opens source captures on tap
- Failure signals:
  - backfill writes no payload for obviously eligible assist-archive records
  - Day Detail still foregrounds AI/system states ahead of the day itself
  - source rows stop opening the capture detail sheet
- Regression surface:
  - review retrieval
  - legacy assist archive persistence
  - DevTools diagnostics
  - Day Detail navigation and source browsing

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=5D4E15F7-AC23-454E-B304-9CFC19AD13A1' -only-testing:'Life NarattorTests' test`

## Rollback Notes
- Revert `ReviewMaterialRepairService` plus its call sites in `MemoryIndexStore` and `CaptureFeedViewModel` to restore the previous no-backfill behavior.
- Revert `DevToolsReviewMaterialView` additions if the manual repair tool is not desired.
- Revert `DayDetailScreen` to restore the previous section order and presentation.
- No schema migration is involved; backfill writes standard artifact rows and can be safely reverted with code.

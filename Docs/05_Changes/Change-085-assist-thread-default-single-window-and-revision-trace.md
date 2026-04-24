# Change-085 — Assist Thread Default Single Window and Revision Trace

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistFlow/Threading/Revision/UI
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Moved `记录/助手` switch to the input area (above input box) for faster mode switching.
- Upgraded Assist flow from transient chat to persisted thread model:
  - default single active thread.
  - user can manually open a new thread (`新建窗口`).
  - split only happens via user action (`拆分`) or explicit user request; no automatic forced split.
  - after `记录到记录页`, current thread is closed and a fresh thread is created.
- Added thread persistence and history reopen:
  - thread meta persisted via `ArtifactEntity(assist_thread_meta)`.
  - thread messages persisted via `ArtifactEntity(assist_thread_message)`.
  - closed thread can be reopened from `窗口` menu and continued.
- Added record-thread linkage and non-destructive time semantics:
  - `CaptureEntity.sourceThreadID` added.
  - first confirm in a thread creates a log record linked to thread.
  - later confirm on reopened thread revises the linked record while keeping original `createdAt` unchanged.
  - each revision writes a trace artifact `capture_revision`.
- Added revision visibility in record list status: `已修订 N 次`.

## Files Changed
- `Life Narattor/Data/CaptureEntity.swift`
- `Life Narattor/Data/PersistenceController.swift`
- `Life Narattor/Models/CaptureItem.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-038.md`
- `Docs/05_Changes/Change-085-assist-thread-default-single-window-and-revision-trace.md`

## Contracts/DB changes
- Added optional field on capture model: `sourceThreadID (UUID?)`.
- Reused `ArtifactEntity` for thread meta/message and capture revision traces.

## User-visible impact
- Mode switch is now near the input area.
- Assist behaves as a thread workspace by default.
- Confirming records closes current thread and opens a new one automatically.
- Historical thread can be reopened for further adjustment.
- Updated records keep original time and show revision count.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`
2. Manual (pending):
   - `VRF-006` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

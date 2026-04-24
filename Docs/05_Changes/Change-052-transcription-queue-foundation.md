# Change-052 — Transcription Queue Foundation (Non-AI)

## Meta
- Date: 2026-03-06
- Owner: Codex (GPT-5)
- Scope: Voice/Queue/Docs
- Related Skills: speech-transcription, error-handling-standard, acceptance-testing-min-bar
- Related ADRs: None
- Status: Done

## What changed
- Refactored transcription from one-shot delay into per-capture queue tasks.
- Added task dedupe/cancel behavior by `captureID` to avoid overlapping transcription runs.
- Added auto-restore for `pending`/`offline` voice captures during feed load.
- Added offline polling loop (status kept as `offline`) with automatic resume when offline simulation is cleared.
- Added missing-audio-file guard to fail safely.
- Updated placeholder list wording to match current capability.

## Files touched
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/AudioRecorderOverlayView.swift`
- `Docs/01_Product/Placeholder_Features.md`
- `Docs/04_Sessions/2026-03-06_session-005.md`
- `Docs/05_Changes/Change-052-transcription-queue-foundation.md`

## Contracts/DB changes
- None.
- Existing `CaptureEntity` fields reused (`audioPath`, `transcriptionStatus`, `transcriptText`).

## User-visible impact
- Voice captures in `pending/offline` states are now recoverable by queue logic instead of relying on a single delayed task.
- Offline simulation now behaves like a queued retry loop.

## Verification steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
2. Expected:
   - `** BUILD SUCCEEDED **`
3. Manual acceptance (Xcode):
   - Enable offline simulation in DevTools and stop a voice recording -> status should remain `离线中 · 稍后自动转写`.
   - Disable offline simulation -> queue should continue and reach `转写完成` (simulated text).
   - Trigger retry repeatedly -> only latest run should remain active.

## Rollback plan
- Revert the files listed above.
- Remove this change/session log pair if full rollback is required.

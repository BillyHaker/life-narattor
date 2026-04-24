# Change-067 — Transcription Debug Observability In DevTools

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/DevTools/Diagnostics
- Related Skills: dev-logging-system, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Added transcription debug event model/store:
  - `TranscriptionDebugEvent`
  - `TranscriptionDebugStore`
- Added instrumentation in transcription flow:
  - `HybridVoiceTranscriptionService` (AI primary + fallback events)
  - `CaptureFeedViewModel` queue lifecycle events (enqueued/pending/retry/offline/failed/completed)
- Added new DevTools page:
  - `Transcription Debug` in `DevToolsRootView`
  - Shows current provider path, latest status, last error code, last fallback reason, and recent event timeline.
- Added diagnostics export data:
  - `transcription_debug.json`

## Files Changed
- `Life Narattor/DevTools/LogStore.swift`
- `Life Narattor/VoiceTranscriptionService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/DevTools/DevToolsRootView.swift`
- `Life Narattor/DevTools/DiagnosticsExporter.swift`
- `Docs/04_Sessions/2026-03-08_session-020.md`
- `Docs/05_Changes/Change-067-transcription-debug-observability-in-devtools.md`

## Contracts/DB changes
- None.

## User-visible impact
- DevTools now directly explains transcription behavior during debugging:
  - current primary provider path,
  - last fallback reason,
  - last normalized error code,
  - recent chronological event list.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`
2. Manual:
   - Open DevTools → `Transcription Debug`.
   - Trigger a voice transcription.
   - Confirm event list updates and summary fields reflect latest status/error/fallback.

## Rollback Notes
- Revert files listed in `Files Changed`, then rebuild.

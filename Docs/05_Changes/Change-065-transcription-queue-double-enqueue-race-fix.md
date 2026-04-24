# Change-065 — Transcription Queue Double-Enqueue Race Fix

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/VoiceTranscription/Queue
- Related Skills: error-handling-standard, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Updated transcription enqueue order in:
  - `stopRecording(...)`
  - `retryTranscription(...)`
- New order:
  - `saveContext()`
  - `enqueueTranscription(...)`
  - `loadCaptures()`

## Why
- Previous order allowed `loadCaptures()` to restore pending transcription and enqueue one task, then method-level enqueue added a second competing task.
- Under race timing, one task could briefly write a failure/offline state before the other completed, producing short-lived "转写失败" flashes.

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-08_session-018.md`
- `Docs/05_Changes/Change-065-transcription-queue-double-enqueue-race-fix.md`

## Contracts/DB changes
- None.

## User-visible impact
- During normal waiting period, transient false "transcription failed" flashes should be eliminated.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`

## Rollback Notes
- Revert files listed in `Files Changed`, then rebuild.

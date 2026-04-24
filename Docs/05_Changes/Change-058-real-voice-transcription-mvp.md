# Change-058 — Real Voice Transcription MVP

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: Voice/Transcription
- Related Skills: capture-ui, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Implemented real voice transcription path (MVP) using iOS `Speech` framework.
- Added new transcription service:
  - `VoiceTranscribing` protocol.
  - `SystemSpeechTranscriptionService` implementation with:
    - speech authorization request,
    - locale fallback (`zh-CN` -> `en-US` -> current locale),
    - final transcript extraction,
    - explicit error types.
- Replaced hardcoded mock transcript completion in `CaptureFeedViewModel` queue:
  - now calls real transcription service with timeout.
  - keeps existing simulation flags (`failure`, `offline`) for dev testing.
  - retries on transient conditions and marks failed on non-retryable errors.
- Added speech permission usage string to app build settings:
  - `NSSpeechRecognitionUsageDescription`.

## Files Changed
- `Life Narattor/VoiceTranscriptionService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor.xcodeproj/project.pbxproj`
- `Docs/04_Sessions/2026-03-07_session-011.md`
- `Docs/05_Changes/Change-058-real-voice-transcription-mvp.md`

## Contracts/DB changes
- None.

## User-visible impact
- After voice recording, transcript text is now generated from actual speech recognition instead of fixed placeholder text.
- If speech service is temporarily unavailable/network unstable, status can enter offline retry loop.
- If permission is denied or recognition fails non-transiently, status becomes failed and supports manual retry.

## Verification Steps
1. Build:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `EXIT:0`
2. Manual Xcode check:
   - Run app, record a short voice note, stop recording.
   - Expected: item status moves from `正在转写…` to `转写完成`, and detail page shows recognized transcript text.

## Rollback Notes
- Revert all files in `Files Changed`, then rebuild.

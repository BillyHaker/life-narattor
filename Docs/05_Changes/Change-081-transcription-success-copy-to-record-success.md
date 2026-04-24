# Change-081 — Transcription Success Copy To Record Success

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/UICopy
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Updated display copy:
  - `TranscriptionStatus.completed` from `转写完成` to `记录成功`.

## Files Changed
- `Life Narattor/Models/VoiceModels.swift`
- `Docs/04_Sessions/2026-03-08_session-034.md`
- `Docs/05_Changes/Change-081-transcription-success-copy-to-record-success.md`

## Contracts/DB changes
- None.

## User-visible impact
- Success state wording better reflects user goal (recording success) instead of implementation detail (transcription success).

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-status-copy/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-status-copy-derived build`
   - Result: `EXIT:0`

## Rollback Notes
- Revert files listed in `Files Changed`.

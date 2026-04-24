# Change-068 — Transcription Debug Store Tests

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: Tests/Observability
- Related Skills: dev-logging-system, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Added targeted unit tests for `TranscriptionDebugStore`:
  - fallback summary updates (`lastFallbackReason`, `lastErrorCode`)
  - voice error normalization (`voice.permission_denied`)
  - provider label resolution for mock AI service (`ai.mock`)

## Files Changed
- `Life NarattorTests/TranscriptionDebugStoreTests.swift`
- `Docs/04_Sessions/2026-03-08_session-021.md`
- `Docs/05_Changes/Change-068-transcription-debug-store-tests.md`

## Contracts/DB changes
- None.

## User-visible impact
- No direct UI change.
- Improves reliability of DevTools transcription observability by protecting core mappings with automated tests.

## Verification Steps
1. Run targeted tests:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/life-narrator-main-derived-test test -only-testing:'Life NarattorTests/TranscriptionDebugStoreTests'`
   - Expected: `EXIT:0`

## Rollback Notes
- Revert files listed in `Files Changed`.

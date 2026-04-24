# Change-071 — Transcription Retry Backoff And Max Attempts

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/VoiceTranscription/RetryPolicy
- Related Skills: error-handling-standard, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Added bounded retry policy in transcription queue:
  - max retries: 5 attempts
  - exponential backoff: 2s → 4s → 8s → 16s → 30s (cap)
- Added retry exhaustion terminal behavior:
  - after max attempts, status switches to `failed` and queue stops.
- Improved retry/failure reason text:
  - retry messages include attempt index and next retry delay.
  - terminal failure reason now differentiates `AIServiceError` cases (e.g., HTTP status).

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-08_session-024.md`
- `Docs/05_Changes/Change-071-transcription-retry-backoff-and-max-attempts.md`

## Contracts/DB changes
- None.

## User-visible impact
- Prevents endless retry loops on persistent transient failures.
- Users see clearer retry progress and final error explanation.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`
2. Manual:
   - Force retryable error path (e.g., temporary backend/network issue).
   - Verify retry message increments attempts with delay.
   - Verify final failure appears after max retry count.

## Rollback Notes
- Revert files listed in `Files Changed`.

# Change 208 — Beta release hardening

## Summary
Hardened TestFlight/Release boundaries and updated beta submission documentation.

## Changes
- Release/TestFlight AI calls require backend proxy; direct local OpenAI fallback is Debug-only.
- Release/TestFlight transcription requires AI/backend path and no longer silently falls back to local speech on backend failure.
- Backend transcription default changed to Doubao and documented in `server/.env.example` and `server/README.md`.
- Dev tooling remains debug-only and is documented as hidden from TestFlight/Release.
- Removed old weekly/monthly review links from `ReviewHomeScreen`.
- Updated legacy weekly/monthly review screens to rolling `7 天回顾` / `30 天回顾` language and ranges.
- Softened Timeline snapshot copy so it does not imply realtime guaranteed AI story generation.
- Removed mock AI provider label expectation from tests.
- Rebuilt preflight checklist and added AI Review evaluation samples.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/VoiceTranscriptionService.swift`
- `Life Narattor/DevTools/FeatureFlags.swift`
- `Life Narattor/DevTools/LogStore.swift`
- `Life Narattor/ContentView.swift`
- `Life Narattor/Models/ReviewModels.swift`
- `Life Narattor/Screens/ReviewHomeScreen.swift`
- `Life Narattor/Screens/WeeklyReviewScreen.swift`
- `Life Narattor/Screens/MonthlyReviewScreen.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Life NarattorTests/TranscriptionDebugStoreTests.swift`
- `server/server.js`
- `server/.env.example`
- `server/README.md`
- `Docs/06_Testing/Beta-Preflight-Checklist.md`
- `Docs/06_Testing/Beta-Launch-Checklist.md`
- `Docs/06_Testing/Beta-Review-Notes.md`
- `Docs/06_Testing/App-Store-Submission-Copy.md`
- `Docs/06_Testing/AI-Review-Evaluation-Samples.md`

## Verification
- `git diff --check` passed.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed on iPhone 17 Pro Max simulator.
- Static scans found no UI-surface legacy `本周/本月` labels and no mock/default OpenAI transcription residue in app/server paths.

## Rollback
Revert this change commit. If server-side Doubao is not ready, override backend env with an explicit non-default provider rather than restoring client-side model keys.

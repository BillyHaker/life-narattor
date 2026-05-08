# Change 237 - Voice Transcription Production Recovery

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Backend/Voice Transcription
- Status: Done
- Related ADR: None
- Related session: [2026-05-08 Session 002](../04_Sessions/2026-05-08_session-002.md)

## Goal
Restore production voice transcription reliability and fix stale retry-failure UI.

## Files Changed
- `server/server.js`
- `server/.env.example`
- `server/README.md`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Models/CaptureItem.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/CaptureCardView.swift`

## Implementation
- Added preferred Doubao ASR `DOUBAO_API_KEY` support while preserving legacy `DOUBAO_APP_ID` + `DOUBAO_ACCESS_TOKEN` headers.
- Added `DOUBAO_USER_ID` so the ASR user uid is not coupled to the app credential.
- Added OpenAI audio transcription fallback for known Doubao configuration/auth/format failures when OpenAI credentials exist.
- Added sanitized transcription error mapping for known provider setup/auth failures.
- Added token-based iOS transcription task cleanup so old/cancelled tasks cannot clear newer tasks.
- Refined voice capture status UI so `正在转写…` is shown only for active pending transcription; failed/offline captures expose retry.

## User-visible impact
- Voice transcription is less likely to be blocked by a single Doubao credential/resource issue after backend deployment.
- If transcription still fails, users should see a stable failure/retry state instead of a stuck `正在转写…` card.
- Backend operators get clearer 503 error categories for transcription provider issues.

## Verification
- `git diff --check` passed.
- `npm run check` passed in `server/`.
- Local fallback smoke test with a mock OpenAI audio endpoint returned HTTP 200 transcript JSON.
- iOS Debug Simulator build passed.
- Full `xcodebuild test` against iPhone 17 Pro Max simulator passed, including unit tests and UI launch tests.

## Manual Verification
1. Deploy the backend to Render.
2. Confirm Render environment has either a valid `DOUBAO_API_KEY` or a valid `OPENAI_API_KEY` fallback.
3. Install the current App Store build and record a voice note.
4. Confirm success path reaches `已记录` and shows transcript.
5. Temporarily break provider credentials in a non-production environment and confirm failure path shows retry rather than indefinite `正在转写…`.

## Rollback
- Revert the final commit.
- No database migration or data format change is involved.

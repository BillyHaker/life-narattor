# Change 178 — Switch Default Transcription to Doubao

## What Changed
- Switched the backend default transcription provider from OpenAI to Doubao.
- Kept the provider override mechanism intact via `TRANSCRIBE_PROVIDER`.
- Improved the missing Doubao configuration error so local testing and beta setup failures are easier to diagnose.

## Files Touched
- `server/server.js`
- `Docs/04_Sessions/2026-03-29_session-001.md`
- `Docs/05_Changes/Change-178-switch-default-transcription-to-doubao.md`

## User-Visible Impact
- Audio transcription now defaults to Doubao ASR when no explicit `TRANSCRIBE_PROVIDER` is set.
- If Doubao environment variables are missing, the backend now returns a clearer configuration error.

## Verification Steps
1. Run `node --check 'server/server.js'`.
2. Build the iOS app:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
3. Manual path:
   - Open the app.
   - Create a voice capture.
   - Confirm transcription succeeds when Doubao env is configured.
   - If Doubao env is missing, confirm the backend exposes a clear configuration error.

## Rollback Notes
- Revert `server/server.js` to restore OpenAI as the default transcription provider.
- No schema or persistence changes are involved.

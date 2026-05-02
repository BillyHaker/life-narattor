# Change 227 - Render AI Base URL

## Goal
Use the live Render backend from Release/App Store builds so AI features no longer depend on local debug-only environment variables.

## Files Changed
- `Life Narattor/AppConfig.plist`
- `Docs/04_Sessions/2026-05-02_session-006.md`
- `Docs/05_Changes/Change-227-render-ai-base-url.md`

## Implementation
- Set bundled `AIBaseURL` to `https://life-narrator-api.onrender.com`.
- Verified the Render service is live and reachable at `/healthz`.

## Verification
- `curl -sS -i --max-time 20 https://life-narrator-api.onrender.com/healthz` returned HTTP 200 and `{"status":"ok"}`.
- `plutil -lint "Life Narattor/AppConfig.plist"` passed.
- Xcode MCP `BuildProject` passed for `windowtab1`.

## Manual Verification
- Archive a new build and install it from TestFlight/App Store.
- Verify record splitting, assistant, AI review, transcription, and in-app feedback against the Render backend.

## Rollback
- Reset `Life Narattor/AppConfig.plist` `AIBaseURL` to an empty string.

# Change-063 — Doubao Transcription Provider Switch

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: Server/AI/Transcription
- Related Skills: ai-interaction, error-handling-standard, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Added server-side transcription provider routing controlled by `TRANSCRIBE_PROVIDER`.
  - `openai` (default): existing multipart pass-through behavior.
  - `doubao`: converts uploaded audio to base64 JSON and forwards to configured Doubao ASR endpoint.
- Added Doubao configuration support:
  - `DOUBAO_ASR_URL`
  - `DOUBAO_APP_ID`
  - `DOUBAO_ACCESS_TOKEN`
  - `DOUBAO_RESOURCE_ID` (default `volc.bigasr.auc_turbo`)
  - `DOUBAO_MODEL_NAME` (default `bigmodel`)
- Added multipart parsing and transcript extraction helpers in `server/server.js`.
- Updated server docs and env template.

## Files Changed
- `server/server.js`
- `server/.env.example`
- `server/README.md`
- `Docs/04_Sessions/2026-03-07_session-016.md`
- `Docs/05_Changes/Change-063-doubao-transcription-provider-switch.md`

## Contracts/DB changes
- No iOS API contract change (`POST /v1/transcribe` unchanged).
- No DB schema changes.

## User-visible impact
- No change by default.
- After setting `TRANSCRIBE_PROVIDER=doubao` and valid credentials, voice transcription requests route to Doubao via backend proxy.

## Verification Steps
1. Syntax check:
   - `node --check '/private/tmp/life-narrator-codex-fix/server/server.js'`
2. iOS compile gate:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `EXIT:0`

## Rollback Notes
- Revert files listed in `Files Changed`, then restart server and rebuild iOS app.

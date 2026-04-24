# Change-062 — Backend Transcription Endpoint

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: AI/Voice/Backend
- Related Skills: ai-interaction, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- App side:
  - Implemented `BackendAIService.transcribeAudio(fileURL:locale:)`.
  - Uses multipart upload to backend `/v1/transcribe`.
  - Sends `model=whisper-1`, optional `language`, and audio file data.
- Server side:
  - Added `POST /v1/transcribe`.
  - Added `OPENAI_AUDIO_BASE` config (default OpenAI audio transcription endpoint).
  - Route validates multipart request, forwards raw body to OpenAI, returns `{ text }`.
- Docs:
  - Updated `server/README.md` with new env and endpoint details.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `server/README.md`
- `Docs/04_Sessions/2026-03-07_session-015.md`
- `Docs/05_Changes/Change-062-backend-transcription-endpoint.md`

## Contracts/DB changes
- No DB change.
- API additive change: proxy now supports `POST /v1/transcribe`.

## User-visible impact
- With `LIFENARRATOR_AI_BASE` configured and AI-priority enabled, transcription can be served by backend proxy rather than direct OpenAI from client.
- Existing local fallback path remains active for resilience.

## Verification Steps
1. iOS build:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `EXIT:0`
2. Server syntax:
   - `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
   - Expected: success.

## Rollback Notes
- Revert the files listed in `Files Changed`, then rerun verification commands.

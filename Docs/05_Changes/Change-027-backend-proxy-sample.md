# Change-027 — Backend proxy sample with safeguards

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: AI / Security
- Related Skills:
  - Skills/ai-interaction/SKILL.md
- Related ADRs:
  - Docs/03_Decisions/ADR-008-backend-proxy-for-ai.md
- Status: Done

## What changed
- Added a minimal Node.js proxy server that forwards to OpenAI and applies basic safeguards.
- Included rate limiting, daily quota, and token allowlist controls.

## Files touched
- server/server.js
- server/README.md
- server/.env.example

## Contracts/DB changes
- None.

## User-visible impact
- Enables App Review access to AI without embedding API keys in the app.

## Verification steps
1) Set `OPENAI_API_KEY` in `server/.env` and run `node server.js`.
2) Call `GET /healthz` → returns `{ "status": "ok" }`.
3) Send a POST to `/v1/quick/ack` with a valid token; response returns ack JSON.
4) Exceed `RATE_LIMIT_RPM` → returns 429.

## Rollback plan
- Remove the `server/` folder.

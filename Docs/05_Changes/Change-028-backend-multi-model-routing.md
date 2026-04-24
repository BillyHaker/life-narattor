# Change-028 — Backend multi-model routing

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: AI / Backend
- Related Skills:
  - Skills/ai-interaction/SKILL.md
- Related ADRs:
  - Docs/03_Decisions/ADR-008-backend-proxy-for-ai.md
- Status: Done

## What changed
- Added per-route model routing for Quick/Assist/Deep in the proxy server.
- Documented new model env vars.

## Files touched
- server/server.js
- server/README.md
- server/.env.example

## Contracts/DB changes
- None.

## User-visible impact
- Different requests can use different models without changing the client app.

## Verification steps
1) Set `MODEL_QUICK`, `MODEL_ASSIST`, `MODEL_DEEP` in `server/.env`.
2) Run `node server.js` and call `/v1/quick/ack` and `/v1/assist`.
3) Confirm the OpenAI request uses the configured model (via server logs or OpenAI logs).

## Rollback plan
- Revert changes to `server/server.js`, `server/README.md`, and `server/.env.example`.

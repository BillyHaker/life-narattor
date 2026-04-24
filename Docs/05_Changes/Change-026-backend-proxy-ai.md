# Change-026 — Backend proxy AI integration

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
- Added BackendAIService that calls proxy endpoints for QuickAck, Assist, and DeepTask.
- Added backend configuration via env vars `LIFENARRATOR_AI_BASE` and `LIFENARRATOR_AI_TOKEN`.
- Factory now prefers backend when configured.

## Files touched
- Life Narattor/Life Narattor/AI/AIService.swift

## Contracts/DB changes
- None.

## User-visible impact
- When backend is configured, AI calls route through the proxy.

## Verification steps
1) In Xcode scheme, set env `LIFENARRATOR_AI_BASE` (and optional `LIFENARRATOR_AI_TOKEN`).
2) Disable Mock AI in DevTools.
3) Create a capture → QuickAck/Assist should hit proxy endpoints.
4) Remove backend env vars → app falls back to OpenAI (if key is set) or Mock AI.

## Rollback plan
- Revert `Life Narattor/Life Narattor/AI/AIService.swift`.

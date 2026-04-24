# ADR-008 — Backend proxy for AI access (review-safe)

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: Security / API
- Related Skills: Skills/ai-interaction/SKILL.md
- Status: Accepted

## Context
- App review must exercise AI features.
- Client-embedded API keys are unsafe and can be extracted, leading to abuse.

## Options
1) Embed API key in the iOS app.
2) Use a backend proxy that holds the key and enforces limits/whitelists.
3) Remove AI features for review.

## Decision
- Implement a backend proxy integration in the app.
- Add server-side protections: rate limits, per-user quotas, and review-account whitelisting.
- Keep client-side OpenAI access for local dev only (env var).

## Rationale
- Enables App Review access without exposing secrets.
- Allows enforcing limits and monitoring usage.

## Consequences
- Requires a backend service before production release.
- App needs base URL and token configuration.

## Validation
- With `LIFENARRATOR_AI_BASE` set, app routes AI requests to backend.
- Without backend config, app falls back to OpenAI (dev) or Mock AI.

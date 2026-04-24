# ADR-007 — OpenAI key handling (dev-only client access)

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: Security / API
- Related Skills: Skills/ai-interaction/SKILL.md
- Status: Accepted

## Context
- The app needs to use OpenAI for QuickAck and Assist Archive in V1.
- Client-side apps should not embed API keys; keys must be kept out of the repo and ideally behind a backend.

## Options
1) Embed API key in app bundle.
2) Load API key from environment variables for local development only.
3) Route all requests through a backend (recommended for production).

## Decision
- Use environment variables for local development.
- Keep client-side OpenAI access gated behind a feature flag and require a runtime key.
- Plan to move to a backend before production.

## Rationale
- Avoids committing secrets and reduces leak risk.
- Enables local testing without blocking current UI work.
- Aligns with OpenAI key safety guidance for client apps.

## Consequences
- Requires developers to set `OPENAI_API_KEY` in Xcode scheme/run environment.
- Production build must swap to backend or remove client-side calls.

## Validation
- App uses Mock AI if no key is set or if Mock AI feature flag is enabled.
- OpenAI calls work only when key is present and Mock AI is disabled.

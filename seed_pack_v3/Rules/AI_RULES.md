---
name: ai-rules
description: Universal rules for AI-assisted development. Keep changes minimal, verifiable, and traceable.
version: 1.0
---

# AI_RULES (Universal)

## 1) Follow the spec-first workflow
- Specs live in `Skills/`.
- If a behavior is implemented, it must be described in a relevant Skill (or generated project skill).

## 2) Keep changes minimal and reversible
- Prefer small increments.
- Always include a rollback plan for risky changes.

## 3) Always verify
- For UI: provide manual verification steps (simulator/device).
- For data/contracts: provide fixtures/examples.

## 4) No silent refactors
- If you refactor, explain why and what changed.

## 5) Respect privacy & security
- Never log/export secrets or tokens.
- Follow `Skills/privacy-redaction-standard`.

## 6) Use the project’s logging process
- Maintain Session/ADR/Change/Handover as required by `Rules/DEV_LOG_RULES.md`.

# Change-025 — OpenAI client configuration (dev)

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: AI / Security
- Related Skills:
  - Skills/ai-interaction/SKILL.md
- Related ADRs:
  - Docs/03_Decisions/ADR-007-openai-client-key-dev-only.md
- Status: Done

## What changed
- Added OpenAI service implementation using the Responses API with JSON schema outputs.
- Added environment-based API key loading and factory selection between Mock/OpenAI.

## Files touched
- Life Narattor/Life Narattor/AI/AIService.swift
- Life Narattor/Life Narattor/ContentView.swift

## Contracts/DB changes
- None.

## User-visible impact
- When `OPENAI_API_KEY` is provided and Mock AI is disabled, AI calls can use OpenAI.
- Otherwise the app continues using mock AI responses.

## Verification steps
1) In Xcode scheme, set environment variable `OPENAI_API_KEY`.
2) Run app → DevTools → Feature Flags → turn off “Mock AI”.
3) Create a new capture → QuickAck/Assist flow should use OpenAI.
4) Remove the environment variable → app falls back to Mock AI.

## Rollback plan
- Revert `Life Narattor/Life Narattor/AI/AIService.swift` and `Life Narattor/Life Narattor/ContentView.swift`.

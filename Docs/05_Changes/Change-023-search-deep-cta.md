# Change-023 — Search deep CTA placeholder

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Search
- Related Skills:
  - Skills/search/SKILL.md
- Related ADRs: None
- Status: Done

## What changed
- Added a “用 AI 帮我找” CTA placeholder in Search when a query is present.
- CTA shows a short placeholder alert instead of triggering AI.

## Files touched
- Life Narattor/Life Narattor/Screens/SearchScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Users can see the AI search entry point without any actual AI call.

## Verification steps
1) Open Search and type a query.
2) “用 AI 帮我找” appears.
3) Tap it → alert explains deep search is not enabled yet.

## Rollback plan
- Revert `Life Narattor/Life Narattor/Screens/SearchScreen.swift`.

# Change-041 — AI connection test (DevTools)

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools
- Related Skills: devtools-debug-suite
- Related ADRs:
- Status: Done

## What changed
- Added a DevTools view to test AI connectivity using `AIServiceFactory.make()` and a sample QuickAck request.

## Files touched
- `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`

## Contracts/DB changes
- None.

## User-visible impact
- DevTools now includes an “AI Connection Test” screen to validate OpenAI connectivity via env var.

## Verification steps
1) Set `OPENAI_API_KEY` in the app scheme environment variables.
2) Open DevTools → AI Connection Test.
3) Tap “测试 OpenAI 连接” and confirm the status updates to “连接成功”.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`.

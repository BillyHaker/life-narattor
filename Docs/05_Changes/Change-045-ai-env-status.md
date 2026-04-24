# Change-045 — AI env status display

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools
- Related Skills: devtools-debug-suite
- Related ADRs:
- Status: Done

## What changed
- Added environment status display for `OPENAI_API_KEY` and `LIFENARRATOR_AI_BASE` in the AI Connection Test view (masked key suffix).

## Files touched
- `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`

## Contracts/DB changes
- None.

## User-visible impact
- DevTools can now confirm whether the API key is visible to the app process.

## Verification steps
1) Open DevTools → AI Connection Test.
2) Confirm OPENAI_API_KEY status shows "已设置（末四位 …）".
3) Confirm LIFENARRATOR_AI_BASE shows "未设置" if not set.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`.

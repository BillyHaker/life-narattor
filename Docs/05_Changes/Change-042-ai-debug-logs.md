# Change-042 — AI debug logs

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools
- Related Skills: devtools-debug-suite
- Related ADRs:
- Status: Done

## What changed
- Added temporary LogStore entries to confirm which AI service is selected and whether QuickAck uses Mock or OpenAI.

## Files touched
- `Life Narattor/Life Narattor/AI/AIService.swift`

## Contracts/DB changes
- None.

## User-visible impact
- DevTools Logs will show entries like `AIService=OpenAI` and `QuickAck=OpenAI` when real requests are used.

## Verification steps
1) Open DevTools → Logs.
2) Create a new capture in Record.
3) Confirm logs show `AIService=OpenAI` and `QuickAck=OpenAI`.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/AI/AIService.swift`.

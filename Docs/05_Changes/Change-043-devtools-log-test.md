# Change-043 — DevTools log test button

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools
- Related Skills: devtools-debug-suite
- Related ADRs:
- Status: Done

## What changed
- Added an "Add Test Log" button in DevTools Logs to create a sample log entry for verification.

## Files touched
- `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`

## Contracts/DB changes
- None.

## User-visible impact
- DevTools Logs now has a quick way to generate a log entry.

## Verification steps
1) Open DevTools → Logs.
2) Tap “Add Test Log”.
3) Confirm a new AI log entry appears.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`.

# Change-044 — Fix DevTools tab freeze

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools
- Related Skills: devtools-debug-suite
- Related ADRs:
- Status: Done

## What changed
- Deferred `AIServiceFactory.make()` creation inside the AI Connection Test action to avoid repeated log writes during view rendering.

## Files touched
- `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Switching to DevTools no longer triggers a freeze.

## Verification steps
1) Launch app and switch to DevTools tab.
2) Confirm UI remains responsive.
3) Open AI Connection Test and run the test successfully.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`.

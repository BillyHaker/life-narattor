# Change-031 — Capture detail retry init

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI
- Related Skills: speech-transcription, capture-ui
- Related ADRs:
- Status: Done

## What changed
- Added explicit initializer to `CaptureDetailSheet` to accept the optional transcription retry callback without relying on memberwise defaults.

## Files touched
- `Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift`

## Contracts/DB changes
- None.

## User-visible impact
- None directly; enables the retry button to call the provided handler reliably.

## Verification steps
1) Open Record tab.
2) Tap a voice capture to open the detail sheet.
3) In 原始 tab, tap “重新转写” and confirm no crash (handler invoked).

## Rollback plan
- Revert `CaptureDetailSheet` init changes in `Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift`.

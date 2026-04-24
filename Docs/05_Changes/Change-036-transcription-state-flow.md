# Change-036 — Transcription state flow

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI/DevTools
- Related Skills: speech-transcription
- Related ADRs:
- Status: Done

## What changed
- Added dev feature flags to simulate transcription offline/failure states.
- Updated recording and retry flows to surface offline/failed statuses in the record feed and detail views.

## Files touched
- `Life Narattor/Life Narattor/DevTools/FeatureFlags.swift`
- `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`
- `Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Developers can toggle transcription failure/offline simulation in DevTools, and the record feed shows correct status lines.

## Verification steps
1) Open DevTools → Feature Flags and enable “Simulate Transcription Offline”.
2) Create a voice capture and confirm it shows “离线中 · 稍后自动转写”.
3) Disable Offline, enable “Simulate Transcription Failure”.
4) Retry transcription and confirm it shows “转写失败 · 重试”.

## Rollback plan
- Revert edits in the files listed above.

# Change-040 — Basic audio playback in capture detail

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI
- Related Skills: speech-transcription
- Related ADRs:
- Status: Done

## What changed
- Added a basic audio player controller and wired Play/Pause in the capture detail sheet for voice entries when `audioPath` exists.

## Files touched
- `Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Voice capture detail now supports Play/Pause when an audio file is available; shows “暂无音频” if not.

## Verification steps
1) Open a voice capture detail with a valid `audioPath` file on disk.
2) Tap 播放 and 确认音频播放；再点 暂停。
3) For entries with no audio file, confirm “暂无音频” is shown.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift`.

# Change-054 — Audio Playback Progress + Seek Controls

## Meta
- Date: 2026-03-06
- Owner: Codex (GPT-5)
- Scope: Voice/UI/Playback
- Related Skills: speech-transcription, capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Upgraded capture detail voice playback from basic play/pause to timeline-capable playback:
  - Added progress state (`currentTime`, `duration`) in `AudioPlaybackController`.
  - Added periodic progress synchronization with timer.
  - Added seek/scrub APIs (`beginScrubbing`, `scrub`, `endScrubbing`).
  - Added `load` and `stop` lifecycle methods for safer state reset.
- Updated detail UI for voice captures:
  - Play/pause toggle button.
  - Replay button.
  - Seek slider.
  - `mm:ss` current/duration labels.
  - Stop player on detail sheet disappear.

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Docs/04_Sessions/2026-03-06_session-007.md`
- `Docs/05_Changes/Change-054-audio-playback-progress-and-seek.md`

## Contracts/DB changes
- None.

## User-visible impact
- Voice capture detail now shows audio timeline progress.
- User can drag slider to jump within recording.
- Playback state is clearer with current time and total duration.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
2. Expected:
   - `** BUILD SUCCEEDED **`
3. Manual acceptance (Xcode):
   - Open a voice capture detail.
   - Tap `播放` and verify timer advances.
   - Drag slider to middle and verify playback jumps.
   - Tap `重播` and verify playback restarts from 00:00.

## Rollback Notes
- Revert the files listed in `Files Changed`, then rebuild to confirm baseline behavior.

# Change-074 — Recording UX Warning And Level Meter

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/Recording/UX
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Added pre-stop warning before max recording duration:
  - at 10 seconds before 5-minute cap, shows notice: auto-stop is imminent.
- Added live microphone level feedback:
  - enabled `AVAudioRecorder` metering and polling in view model.
  - rendered 10-bar meter in `RecordingChipView`.
- Improved interruption/background notices:
  - system interruption and app background now show distinct reason text.
- Hardened recording state cleanup:
  - stop/cancel now consistently cancel warning/meter tasks and reset level.

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/RecordingChipView.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-027.md`
- `Docs/05_Changes/Change-074-recording-ux-warning-and-level-meter.md`

## Contracts/DB changes
- None.

## User-visible impact
- Recording is less abrupt near duration cap.
- Users get immediate confidence that mic input is being captured.
- Save-notice reason is clearer when recording is interrupted/backgrounded.

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-recording-block1/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-recording-block1-derived build`
   - Result: `EXIT:0`
2. Manual (deferred):
   - `VRF-003` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

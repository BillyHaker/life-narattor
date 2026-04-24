# Change-053 — Recording Safety: Duration Cap + Interruption Save

## Meta
- Date: 2026-03-06
- Owner: Codex (GPT-5)
- Scope: Voice/UI/Resilience
- Related Skills: speech-transcription, error-handling-standard, capture-ui, acceptance-testing-min-bar
- Related ADRs: None
- Status: Done

## What changed
- Added recording max duration cap (5 minutes) with automatic stop.
- Added runtime interruption safety:
  - app entering background during recording
  - audio session interruption begin
- On forced stop, recording is saved as partial capture (`语音记录（未完成）`) instead of being dropped.
- Added transient notice UI on record screen for auto/interrupted saves.
- Fixed actor-isolation compile issues introduced by notification callbacks.

## Files touched
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-03-06_session-006.md`
- `Docs/05_Changes/Change-053-recording-safety-cap-and-interrupt.md`

## Contracts/DB changes
- None.

## User-visible impact
- Long recordings are auto-stopped at 5 minutes and preserved.
- Background/interruption no longer risks losing in-progress recording.
- User sees lightweight notice when forced save happens.

## Verification steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
2. Expected:
   - `** BUILD SUCCEEDED **`
3. Manual acceptance (Xcode):
   - Start recording and send app to background -> capture saved as `语音记录（未完成）`.
   - During recording, trigger interruption (if device scenario available) -> partial capture saved.
   - Keep recording to cap (or temporarily lower cap for local test) -> auto-stop and notice shown.

## Rollback plan
- Revert the files above and rebuild.

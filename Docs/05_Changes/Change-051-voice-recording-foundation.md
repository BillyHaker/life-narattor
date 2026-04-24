# Change-051 — Voice Recording Foundation (Non-AI)

## Meta
- Date: 2026-03-06
- Owner: Codex (GPT-5)
- Scope: Voice/UI/Docs
- Related Skills: speech-transcription, capture-ui, error-handling-standard, acceptance-testing-min-bar
- Related ADRs: None
- Status: Done

## What changed
- Replaced voice recording placeholder flow with actual local recording file generation.
- Stored real local `audioPath` when creating voice captures.
- Added permission-denied alert and Settings deep-link in Record screen.
- Added `NSMicrophoneUsageDescription` in project build settings for runtime permission compliance.
- Kept transcription behavior unchanged (still simulated placeholder, intentionally).
- Updated placeholder feature list to reflect completed voice foundation items.

## Files touched
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/01_Product/Placeholder_Features.md`
- `Life Narattor.xcodeproj/project.pbxproj`
- `Docs/04_Sessions/2026-03-06_session-004.md`
- `Docs/05_Changes/Change-051-voice-recording-foundation.md`

## Contracts/DB changes
- None.
- Existing `CaptureEntity.audioPath` field reused; no migration required.

## User-visible impact
- Mic flow now has real recording behavior.
- Permission denied now has actionable guidance.
- Voice capture detail playback can use persisted local audio path.

## Verification steps
1. Compile:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
2. Expected:
   - `** BUILD SUCCEEDED **`
3. Manual acceptance (Xcode):
   - Deny mic permission then tap mic: alert appears with `去设置`.
   - Grant permission and record: stop creates voice capture card.
   - Open detail `原始` tab: play/pause available if file exists.

## Rollback plan
- Revert code files above and restore previous placeholder behavior.
- Remove Session/Change log files from this change if full rollback is required.

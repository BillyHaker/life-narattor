# Change-059 — Recording Timer + Speech Permission Fix

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: Voice/Recording/Transcription/UI
- Related Skills: capture-ui, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Fixed recording duration display not updating:
  - `RecordingChipView` switched to `TimelineView(.periodic)` and computes elapsed time from timeline context date.
- Improved transcription failure handling caused by missing speech permission:
  - Added shared `SpeechAuthorizationManager`.
  - Added speech permission preflight before starting recording.
  - Added dedicated speech permission alert + settings entry in `RecordFeedScreen`.
  - Added runtime permission-denied alert path in transcription queue for retry scenarios.
- Made `VoiceTranscriptionError` equatable for precise branching.

## Files Changed
- `Life Narattor/Views/RecordingChipView.swift`
- `Life Narattor/VoiceTranscriptionService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-03-07_session-012.md`
- `Docs/05_Changes/Change-059-recording-timer-and-speech-permission-fix.md`

## Contracts/DB changes
- None.

## User-visible impact
- Recording chip duration now increments in real time (`00:01`, `00:02`, ...).
- If speech recognition permission is not granted, user sees explicit prompt and can jump to Settings before or after retry.
- Reduces “record succeeded but transcription silently failed” confusion.

## Verification Steps
1. Build:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `EXIT:0`
2. Manual:
   - Start recording and observe timer increments each second.
   - Deny speech permission and start recording:
     - Expected: speech permission alert appears with Settings entry.
   - Grant permission and retry:
     - Expected: transcription can proceed.

## Rollback Notes
- Revert files listed in `Files Changed`, then rebuild.

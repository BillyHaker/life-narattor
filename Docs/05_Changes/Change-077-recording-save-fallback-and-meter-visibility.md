# Change-077 — Recording Save Fallback And Meter Visibility

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/Recording/RuntimeFix
- Related Skills: dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Hardened recording save flow:
  - introduced `VoiceCaptureDraft` and `persistVoiceCapture`.
  - main-context save now checks result; failure no longer pretends success.
  - added fallback save via isolated context sharing the same persistent store coordinator.
  - main context refreshes objects after fallback save success.
- Improved CoreData diagnostics:
  - `saveContext` now returns `Bool` and logs save failures to `LogStore`.
- Improved level meter visibility:
  - recording-level sampling now keeps a minimal baseline floor while actively recording.
  - recorder power normalization adjusted to dB-range normalization.
  - `RecordingChipView` adds `音量` label and clearer bar rendering.

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/RecordingChipView.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-030.md`
- `Docs/05_Changes/Change-077-recording-save-fallback-and-meter-visibility.md`

## Contracts/DB changes
- None.

## User-visible impact
- If save fails, user now sees explicit failure notice instead of misleading success notice.
- Recording capture persistence is more resilient via fallback write path.
- Level meter is easier to observe during recording.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`
2. Manual (pending):
   - Re-test `VRF-003` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

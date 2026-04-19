# Change Log

- Change: Refined assistant voice input UI so recording becomes a single focused mode instead of stacking on top of the normal composer.
- Date: 2026-04-19
- Owner: Codex

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/RecordingChipView.swift`

## Summary
- Switched the assistant bottom input area to render either the normal text composer or the recording UI, never both at once.
- Reworked the recording control into a clearer card with status, timer, level meter, and stop/cancel actions.
- Reduced visual overlap so message bubbles remain readable while recording.

## Verification Steps
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
  - blocked by local simulator runtime availability (`No available simulator runtimes for platform iphonesimulator`)
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' -derivedDataPath /tmp/life-narrator-main-derived-device build`
  - blocked by local signing / provisioning profile state if present in environment

## Rollback Notes
- Revert `RecordFeedScreen.swift` and `RecordingChipView.swift` to restore the previous stacked recording + text input presentation.

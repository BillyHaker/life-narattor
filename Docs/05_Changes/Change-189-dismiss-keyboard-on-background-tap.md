# Change-189 Dismiss Keyboard On Background Tap

## Summary
Added shared focus handling so the record screen dismisses the keyboard when the user taps outside the search field or bottom input field, without breaking list-row interaction.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/CaptureInputBarView.swift`
- `Docs/04_Sessions/2026-04-20_session-001.md`
- `Docs/05_Changes/Change-189-dismiss-keyboard-on-background-tap.md`

## Verification Steps
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
  - result: `BUILD SUCCEEDED`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' -derivedDataPath /tmp/life-narrator-main-derived-device build`
  - result: `BUILD SUCCEEDED`

## Rollback Notes
- Revert the focus-state wiring and background dismissal gestures in `RecordFeedScreen.swift` and `CaptureInputBarView.swift`.

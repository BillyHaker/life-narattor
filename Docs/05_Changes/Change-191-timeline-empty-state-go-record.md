# Change-191 Timeline Empty State Go Record

## Summary
Updated the timeline empty-state CTA so tapping `去记录` switches the app back to the `记录` tab instead of doing nothing.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Docs/04_Sessions/2026-04-21_session-001.md`
- `Docs/05_Changes/Change-191-timeline-empty-state-go-record.md`

## Verification Steps
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-timeline-empty-state-sim build`
  - result: `BUILD SUCCEEDED`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' -derivedDataPath /tmp/life-narrator-timeline-empty-state-device build`
  - result: `BUILD FAILED` because the DerivedData build database was locked by a concurrent build
- `xcodebuild -quiet -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' -derivedDataPath /tmp/life-narrator-timeline-empty-state-device-final build`
  - result: emitted warnings only and did not finish within the session window

## Rollback Notes
- Revert the tab selection wiring in `ContentView.swift` and the `去记录` action in `TimelineScreen.swift`.

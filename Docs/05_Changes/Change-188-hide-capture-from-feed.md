# Change-188 Hide Capture From Feed

## Summary
Added a record-level `隐藏` action that removes a capture from the visible record feed while keeping its split artifacts and analysis data available for AI review and retrieval.

## Files Changed
- `Life Narattor/Data/CaptureEntity.swift`
- `Life Narattor/Data/PersistenceController.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Docs/04_Sessions/2026-04-19_session-001.md`
- `Docs/05_Changes/Change-188-hide-capture-from-feed.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification Steps
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
  - blocked by local simulator runtime availability (`No available simulator runtimes for platform iphonesimulator`)
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' -derivedDataPath /tmp/life-narrator-main-derived-device build`
  - blocked by local signing / provisioning profile availability when targeting generic iOS devices

## Rollback Notes
- Revert the `isHiddenFromFeed` field and feed filtering logic.
- Remove the detail-level `隐藏` action.
- Hidden records were not deleted, so rollback is non-destructive.

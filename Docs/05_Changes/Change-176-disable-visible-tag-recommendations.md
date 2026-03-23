# Change-176 Disable Visible Tag Recommendations

## Summary
Turned off the visible recommended-tag system. Suggested tags are no longer surfaced to users in record detail, and the split/tag pipeline now keeps only hidden suggestions for indexing and recall.

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Life Narattor/Data/AtomTagStore.swift`
- `Life Narattor/Data/AtomizationCoordinator.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-23_session-001.md`
- `Docs/05_Changes/Change-176-disable-visible-tag-recommendations.md`

## Details
- Removed user-facing visible tag recommendation UI from record detail.
- Stopped exposing `isSuggested` tag links through atom detail fetches.
- Stopped applying visible tag suggestions after atomization.
- Updated tag suggestion prompts so visible `suggestions` are expected to remain empty while `hidden_suggestions` continue to support retrieval.

## Verification
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback
- Re-enable visible suggestion assignment and restore the detail UI if the product direction changes.

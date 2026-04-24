# Change-175 Unified Tag Recommendation Sheet

## Summary
Changed tag recommendations in record detail from repeated per-unit panels into a single unified recommendation flow. Users now see one entry card for recommended tags and choose from a dedicated sheet that stays open until they explicitly finish or dismiss it.

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Docs/04_Sessions/2026-03-22_session-001.md`
- `Docs/05_Changes/Change-175-unified-tag-recommendation-sheet.md`

## Details
- Removed per-atom recommended-tag panels from split items.
- Added a single record-level entry card summarizing available recommended tags.
- Added a unified recommendation sheet with explicit `完成` exit and standard drag-to-dismiss support.
- Keeping a suggested tag no longer closes the picker, allowing multiple selections in one pass.

## Verification
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback
- Revert `Life Narattor/Views/CaptureDetailSheet.swift` and remove this change log entry.

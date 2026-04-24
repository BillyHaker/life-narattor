# Change-174 Tag Suggestion CTA Clarity

## Summary
Made recommended tags in record detail clearly read as a user decision point instead of looking like ordinary tags. Suggested tags now sit in a dedicated recommendation card with explicit copy, and each tag presents one clear action: 保留.

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Docs/04_Sessions/2026-03-22_session-001.md`
- `Docs/05_Changes/Change-174-tag-suggestion-cta-clarity.md`

## Details
- Added a `推荐保留的标签` card for suggested tags inside atom rows.
- Added explanatory copy clarifying that accepting a tag means keeping it for future long-term use.
- Turned each suggested tag into a lightweight row with a single `保留` action.
- Split suggested tags and confirmed tags into separate visual groups.
- Added a lightweight post-accept notice to confirm that the recommendation has been kept.

## Verification
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback
- Revert `Life Narattor/Views/CaptureDetailSheet.swift` and remove this change log entry.

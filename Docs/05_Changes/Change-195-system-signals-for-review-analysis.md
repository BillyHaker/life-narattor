# Change-195 System Signals For Review Analysis

## Summary
Added system-derived review signals so AI analysis can consider stable factual context such as date, weekday, time segment, input source, and processing state without adding those facts to the normal tag library.

## Files Changed
- `Life Narattor/Models/RetrievalPlan.swift`
- `Life Narattor/Data/MemoryIndexStore.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-04-24_session-001.md`
- `Docs/05_Changes/Change-195-system-signals-for-review-analysis.md`

## Verification Steps
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
  - result: `BUILD SUCCEEDED`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' build`
  - result: `BUILD SUCCEEDED`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,id=1C886D05-3E2E-45FB-B58B-856D1B5087D0' test`
  - result: `TEST FAILED`
  - reason: `TranscriptionDebugStoreTests.swift` cannot find `MockAIService` in scope.

## Rollback Notes
- Revert `SystemSignal` model additions, `MemoryIndexStore` system-signal derivation, overview admission relaxation, and `system_signals` analysis payload fields.

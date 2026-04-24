# Change 160 — Remove Mock AI paths

## Summary
Removed Mock AI from the app and replaced its fallback behavior with an explicit unavailable-AI path, so testing now reflects the real backend/OpenAI stack instead of synthetic mock responses.

## Files Changed
- /Users/billyha/Desktop/Life Narattor/Life Narattor/AI/AIService.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/FeatureFlags.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/LogStore.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift

## Details
- Removed the `Mock AI` feature flag and Dev toggle.
- Removed `MockAIService` and factory branches that returned mock responses.
- Added `UnavailableAIService` as the explicit fallback when no backend or OpenAI key is configured.
- Updated provider labels and previews to use the new unavailable-AI path instead of mock behavior.
- Confirmed that the previous hidden-tag issue was primarily caused by the mock path returning empty tag suggestions.

## Verification
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- Result: `EXIT:0`

## Rollback Notes
- Restore the `Mock AI` feature flag and mock factory branch.
- Replace `UnavailableAIService` with the prior mock fallback behavior.

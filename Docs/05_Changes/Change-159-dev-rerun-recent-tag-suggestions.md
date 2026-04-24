# Change 159 — Dev rerun recent tag suggestions

## Summary
Added a DevTools maintenance action that reruns tag suggestions for the most recent 10 captures, reusing existing atomization payloads and preserving confirmed tags.

## Files Changed
- /Users/billyha/Desktop/Life Narattor/Life Narattor/ContentView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsTagsView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/Data/AtomTagStore.swift

## Details
- Passed `AIService` into DevTools so the tag browser can run maintenance actions.
- Added a maintenance card to `DevToolsTagsView` with a button to rerun tag suggestions for the latest 10 captures.
- The rerun flow fetches each capture's existing `atomization_payload`, clears only suggested tag links, then requests fresh visible and hidden suggestions.
- Confirmed tags are preserved because only `isSuggested == YES` links are removed before rerun.
- Added progress and summary text for processed, skipped, and failed captures.

## Verification
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- Result: `EXIT:0`

## Rollback Notes
- Remove the maintenance UI from `DevToolsTagsView.swift`.
- Remove `AIService` injection from `ContentView.swift` and `DevToolsRootView.swift`.
- Remove `clearSuggestedTags(for:)` from `AtomTagStore.swift`.

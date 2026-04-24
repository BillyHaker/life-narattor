# Change 158 — Hidden tag generation defaults

## Summary
Fixed the hidden-tag generation path so hidden tags are more likely to be produced and persisted, instead of being silently absent in DevTools.

## Files Changed
- /Users/billyha/Desktop/Life Narattor/Life Narattor/AI/AIService.swift
- /Users/billyha/Desktop/Life Narattor/server/server.js
- /Users/billyha/Desktop/Life Narattor/Life Narattor/Data/AtomTagStore.swift

## Details
- Changed AI tag-suggestion instructions from optional hidden suggestions to a default expectation of 2-5 hidden suggestions.
- Added `target_hidden_suggestions` to the tag-suggestion policy payload for both direct and backend requests.
- Relaxed local hidden-tag filtering so it still blocks generic or sentence-like noise, but keeps more useful hidden retrieval clues.

## Verification
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- Result: `EXIT:0`

## Rollback Notes
- Revert the hidden-tag instruction and policy changes in `AIService.swift` and `server/server.js`.
- Restore the previous `hiddenSuggestionShouldBeKept(_:)` filter in `AtomTagStore.swift`.

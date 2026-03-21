# Change 162 — Dev tag rerun input fix and hidden-tag weighting

## Summary
Fixed the Dev tag-maintenance rerun flow so it targets real record candidates, can reuse assistant-archive structure when atomization payload is missing, and no longer trips strict-schema HTTP400 on tag suggestion. Also adjusted hidden-tag usage so hidden tags can enter the index more freely without dominating retrieval conclusions.

## Files Changed
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsTagsView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/AI/AIService.swift
- /Users/billyha/Desktop/Life Narattor/server/server.js
- /Users/billyha/Desktop/Life Narattor/Life Narattor/Data/MemoryIndexStore.swift

## Details
- Restricted the Dev “rerun recent 10 tag suggestions” candidate set to `mode == log` captures, which removes assistant chat messages from the rerun batch.
- Added a fallback path that derives a minimal `AtomizeResult` from `assist_archive_card` artifacts when a saved record has no `atomization_payload`.
- Aligned the tag-suggestion structured output schema so `score` is required and nullable on both app and backend paths, preventing strict-schema HTTP400 failures.
- Kept hidden tags broadly available for indexing, but reduced their retrieval influence unless they are repeated or reinforced by record-unit tag hints.
- Raised the threshold for `topHiddenTags` in narrative briefs so one-off hidden tags are less likely to surface as summary signals.

## User-visible Impact
- The Dev tag rerun tool now skips fewer legitimate records and gives more realistic diagnostics.
- Hidden tags should begin to appear after rerunning recent record suggestions with a real AI backend configured.
- AI review and retrieval keep access to hidden-tag recall while becoming less likely to over-index on weak hidden signals.

## Verification
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- Result: `EXIT:0`

## Rollback Notes
- Revert the schema changes in `AIService.swift` and `server.js` to restore the previous tag-suggestion contract.
- Revert `DevToolsTagsView.swift` to restore the older rerun candidate selection and payload lookup.
- Revert `MemoryIndexStore.swift` to remove the hidden-tag downweighting and hidden-tag frequency threshold.

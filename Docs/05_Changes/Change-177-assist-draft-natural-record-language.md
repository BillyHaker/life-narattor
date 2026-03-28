# Change-177 Assist Draft Natural Record Language

## Summary
Adjusted assistant-to-record draft generation so saved drafts read like direct record language instead of third-person system summaries.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-29_session-001.md`
- `Docs/05_Changes/Change-177-assist-draft-natural-record-language.md`

## What Changed
- Updated assist-archive prompts to explicitly forbid product-summary wording such as `用户`, `助手`, `AI`, `系统`, `总结`, `摘要`, and `纪要` in titles and draft body content.
- Reframed the generation target as natural Chinese record language that can be saved directly.
- Added a local normalization layer for archive draft titles, context, and record units so accidental third-person summary wording is cleaned before the fullscreen draft editor shows it.

## User-Visible Impact
- Assistant-generated draft titles and正文 should feel more like real notes.
- Drafts should no longer open with lines like `用户咨询…` or `助手建议…`.

## Verification
- `node --check 'server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- Manual check through 助手 -> `整理为记录`.

## Rollback
- Revert prompt changes in `AIService.swift` and `server.js`.
- Revert normalization helpers in `CaptureFeedViewModel.swift`.
- No data migration or schema rollback is required.

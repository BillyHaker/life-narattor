# Change-078 — Record Feed Findability Filter Search Grouping

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/RecordFeed/UI
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Added top retrieval controls on Record screen:
  - scope filter: `今天 / 近7天 / 全部`
  - keyword search box with clear action.
- Replaced day-part-only grouping with date-based sections:
  - grouped by day (`今天/昨天/日期`) and sorted by newest.
  - section header includes count.
- Added per-item meta line:
  - `时间 · 日段 · 输入类型（语音/文字）`.
- Added context-aware empty state:
  - when search has no results, show keyword-specific hint.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-031.md`
- `Docs/05_Changes/Change-078-record-feed-findability-filter-search-grouping.md`

## Contracts/DB changes
- None.

## User-visible impact
- Record list becomes easier to scan and target specific entries.
- Reduces visual clutter for high-volume capture days.

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-record-list-ux/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-record-list-derived build`
   - Result: `EXIT:0`
2. Manual (pending):
   - `VRF-004` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

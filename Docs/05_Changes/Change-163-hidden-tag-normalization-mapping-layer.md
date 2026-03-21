# Change 163 — Hidden Tag Normalization Mapping Layer

## Files Changed
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Models/HiddenTagNormalization.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/AI/AIService.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsTagsView.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Data/MemoryIndexStore.swift`
- `/Users/billyha/Desktop/Life Narattor/server/server.js`
- `/Users/billyha/Desktop/Life Narattor/Docs/04_Sessions/2026-03-21_session-001.md`

## Summary
Added a hidden-tag normalization pipeline that keeps original hidden tags and tag links untouched.
The app now generates a raw-to-canonical mapping for hidden tags using a two-step AI flow:
1. coarse bucket clustering
2. within-bucket synonym normalization

The mapping is stored as an artifact and is applied only at read/index time, so retrieval and AI review can benefit from canonical hidden tags without destructive migrations.

## Verification Steps
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- Manual:
  1. Open `Dev -> All Tags`
  2. Run `重跑最近 10 条记录标签建议`
  3. Run `整理隐性标签`
  4. Confirm canonical groups appear in DevTools
  5. Re-open `AI 回顾` and verify retrieval still works with hidden tags present

## Rollback Notes
- Remove the hidden-tag normalization artifact reads from `MemoryIndexStore`
- Remove the DevTools normalization action and AI endpoints
- Original tag data and tag links remain untouched, so rollback does not require data migration

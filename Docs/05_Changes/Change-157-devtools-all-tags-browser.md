# Change 157 — DevTools all tags browser

## Summary
Added a DevTools screen for browsing all tags, including both visible and hidden tags, to make tag-system inspection easier during testing.

## Files Changed
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsTagsView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift

## Details
- Added a new `DevToolsTagsView` screen that reads `TagEntity` directly from Core Data.
- Supports filtering between visible tags, hidden tags, and all tags.
- Groups tags by `TagType`.
- Each row shows the tag name, whether it is visible or hidden, whether it is a seeded/common tag, its current link count, and its created date.
- Added an `All Tags` entry to `DevToolsRootView`.

## Verification
- Build command:
  - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- Result:
  - `EXIT:0`

## Rollback Notes
- Remove `DevToolsTagsView.swift`.
- Remove the `All Tags` navigation entry from `DevToolsRootView.swift`.

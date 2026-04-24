# Change 161 — Dev rerun tag diagnostics

## Summary
Added per-record diagnostics to the DevTools tag-suggestion rerun action so hidden-tag failures can be diagnosed directly in the UI.

## Files Changed
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsTagsView.swift

## Details
- Added a per-record diagnostic list to the `All Tags` maintenance card.
- Each recent capture now reports one of: updated, updated without hidden suggestions, skipped, or failed.
- The summary now includes the total hidden suggestion count returned across the rerun.
- Failure output is mapped to friendly explanations such as missing AI config, HTTP errors, invalid response, or empty response.

## Verification
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- Result: `EXIT:0`

## Rollback Notes
- Remove the per-record diagnostic UI and summary fields from `DevToolsTagsView.swift`.

# Change 179 — Beta Privacy Intro and Review Notes

## What Changed
- Added a first-launch privacy sheet to state that record content is stored locally by default.
- Added a beta review note draft that summarizes privacy boundary, current scope, and hidden features for submission/review use.
- Updated the beta preflight checklist to reflect these items as completed.

## Files Touched
- `Life Narattor/ContentView.swift`
- `Docs/06_Testing/Beta-Review-Notes.md`
- `Docs/06_Testing/Beta-Preflight-Checklist.md`
- `Docs/04_Sessions/2026-03-29_session-001.md`
- `Docs/05_Changes/Change-179-beta-privacy-intro-and-review-notes.md`

## User-Visible Impact
- First launch now shows a clear local-first privacy notice before normal use.
- Submission/review materials now have a concise note describing the beta scope and privacy boundary.

## Verification Steps
1. Build the app:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Manual path:
   - Launch the app fresh.
   - Confirm the privacy sheet appears.
   - Tap `继续`.
   - Relaunch the app and confirm the sheet does not reappear.

## Rollback Notes
- Revert `ContentView.swift` to remove the first-launch privacy sheet.
- Delete the beta review note and restore the checklist entries.

# Change-064 — CaptureItem `transcriptionErrorReason` Build Fix

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/Models/Build
- Related Skills: error-handling-standard, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Updated `CaptureItem` model property declaration:
  - from `let transcriptionErrorReason: String? = nil`
  - to `var transcriptionErrorReason: String? = nil`

## Why
- With `let ... = nil`, Swift synthesized memberwise initializer does not accept that argument.
- Call sites in `DayDetailScreen` and `TimelineScreen` pass `transcriptionErrorReason:`, causing compile error:
  - `Extra argument 'transcriptionErrorReason' in call`

## Files Changed
- `Life Narattor/Models/CaptureItem.swift`
- `Docs/04_Sessions/2026-03-08_session-017.md`
- `Docs/05_Changes/Change-064-captureitem-transcriptionerror-build-fix.md`

## Contracts/DB changes
- None.

## User-visible impact
- No behavior change.
- Xcode build unblocked.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`

## Rollback Notes
- Revert files listed in `Files Changed` and rebuild.

# Change-083 — Record Feed Build Typecheck Refactor

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/Build/SwiftUI
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Fixed SwiftUI compile timeout in `RecordFeedScreen` by splitting a heavy `body` expression into smaller view units:
  - extracted `contentView`
  - extracted `sectionsScrollView`
  - extracted `bottomInsetView`
  - replaced `@Bindable` local shadowing with explicit `Binding` helpers.
- Fixed initializer mismatch in `CaptureInputBarView` by adding explicit initializer that supports:
  - `showsModePicker` (default `true`)
  - `textPlaceholder` (default record placeholder).

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/CaptureInputBarView.swift`
- `Docs/04_Sessions/2026-03-08_session-036.md`
- `Docs/05_Changes/Change-083-record-feed-build-typecheck-refactor.md`

## Contracts/DB changes
- None.

## User-visible impact
- No behavior regression intended.
- Build stability improved; app should compile and run again in Xcode.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`
2. Failure reproduction evidence captured:
   - previous error: `RecordFeedScreen.swift:22:25 the compiler is unable to type-check this expression in reasonable time`.

## Rollback Notes
- Revert files listed in `Files Changed`.

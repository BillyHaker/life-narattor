# Change-076 — Recording Level Double Type Fix

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/BuildCompatibility
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- In `CaptureFeedViewModel.currentNormalizedPower()`:
  - converted `averagePower` from `Float` to `Double`.
  - used `Foundation.pow(10.0, averagePower / 20.0)` with `Double` literals.
  - returned clamped value using `Double` bounds (`0.0...1.0`).

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-08_session-029.md`
- `Docs/05_Changes/Change-076-recording-level-double-type-fix.md`

## Contracts/DB changes
- None.

## User-visible impact
- No feature behavior change.
- Resolves compile mismatch on toolchains that infer `Float` for the previous expression.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`

## Rollback Notes
- Revert files listed in `Files Changed`.

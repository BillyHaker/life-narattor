# Change-080 — Record Feed Compact Row Density

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/RecordFeed/UI
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Switched Record list item rendering from full `CaptureCardView` to a compact row component.
- Each row now includes only:
  - meta line (`时间 · 日段 · 输入类型`)
  - short summary (2 lines max)
  - status capsule
  - optional retry button for failed/offline voice transcription.
- Reduced section and row spacing to increase scan density per screen.
- Kept row tap navigation to `CaptureDetailSheet` for full details.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-033.md`
- `Docs/05_Changes/Change-080-record-feed-compact-row-density.md`

## Contracts/DB changes
- None.

## User-visible impact
- More records visible at once.
- Faster target-location with less detail noise in list mode.

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-record-compact/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-record-compact-derived build`
   - Result: `EXIT:0`
2. Manual (pending):
   - Re-test `VRF-004` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

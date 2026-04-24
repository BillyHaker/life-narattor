# Change-082 — Record Assist Surface Separation

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/RecordFeed/UI
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Added top-level screen surface switch:
  - `记录` surface
  - `助手` surface
- Split list content by surface:
  - record surface shows record-only compact rows.
  - assist surface shows assist-only cards and actions.
- Split search semantics:
  - search placeholder and empty-state copy now depend on selected surface.
- Input context now follows selected surface:
  - hidden mode picker in input bar.
  - input mode automatically synchronized to `.log` or `.assist`.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/CaptureInputBarView.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-035.md`
- `Docs/05_Changes/Change-082-record-assist-surface-separation.md`

## Contracts/DB changes
- None.

## User-visible impact
- Record and assistant content no longer mix in one list.
- Users can focus on one workflow context at a time.

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-separate-record-assist/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-separate-ui-derived build`
   - Result: `EXIT:0`
2. Manual (pending):
   - `VRF-005` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

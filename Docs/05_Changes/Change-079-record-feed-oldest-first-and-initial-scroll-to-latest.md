# Change-079 — Record Feed Oldest First And Initial Scroll To Latest

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/RecordFeed/Interaction
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Changed Record list ordering to chronological ascending:
  - day sections sorted oldest to newest.
  - items within each day sorted oldest to newest.
- Added first-load auto-navigation to latest record:
  - wrapped list with `ScrollViewReader`.
  - computes latest capture ID and scrolls to bottom target once.
- Added guard state to avoid repeated auto-jumps after initial positioning.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-032.md`
- `Docs/05_Changes/Change-079-record-feed-oldest-first-and-initial-scroll-to-latest.md`

## Contracts/DB changes
- None.

## User-visible impact
- Record chronology now reads top-down in natural time order.
- Opening the screen lands near newest records by default for quick continuation.

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-record-order-scroll/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-record-order-derived build`
   - Result: `EXIT:0`
2. Manual (pending):
   - Re-test `VRF-004` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

# Change 239 - Record Composer Bottom Bar

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Record UX/Bottom Input
- Status: Done
- Related ADR: [ADR-020](../03_Decisions/ADR-020-assistant-as-composer-mode.md)
- Related session: [2026-05-08 Session 004](../04_Sessions/2026-05-08_session-004.md)

## Goal
Make the Record screen bottom area less crowded by moving Assistant from a separate bottom segmented control into the input composer.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/CaptureInputBarView.swift`
- `Docs/03_Decisions/ADR-020-assistant-as-composer-mode.md`
- `Docs/04_Sessions/2026-05-08_session-004.md`
- `Docs/05_Changes/Change-239-record-composer-bottom-bar.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Removed the separate `surfaceSwitcher` from the Record screen bottom inset.
- Added a compact inline `助手` mode button to `CaptureInputBarView` when the old full segmented picker is hidden.
- Changed the input mode binding so Assistant mode also switches the visible Record screen surface and prepares an Assistant thread.
- Enlarged the root tab bar tap area, icon size, and label size slightly for a less cramped Pro Max bottom area.
- Added backlog item `VRF-043` for human visual and interaction checks.

## User-visible impact
- The bottom of the Record screen should feel lighter and more clearly layered.
- Users can still choose ordinary recording or Assistant, but Assistant is now an input mode button rather than a second bottom navigation bar.
- The app-level Tab Bar should feel more comfortable to tap on larger devices.

## Verification
- Debug simulator build passed.
- Xcode simulator tests were attempted but could not run because CoreSimulatorService was unavailable and the requested simulator device was not discoverable.

## Manual Verification
- Open Record screen and check bottom layout.
- Send normal text record.
- Switch to Assistant mode and send text.
- Switch back to record mode.
- Start and stop voice recording.
- Check keyboard presentation.

## Rollback
- Revert the final commit. No data migration or backend change is involved.

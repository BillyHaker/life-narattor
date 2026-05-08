# Change 240 - Restore Layered Record Controls

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Record UX/Bottom Navigation
- Status: Done
- Related ADR: [ADR-021](../03_Decisions/ADR-021-preserve-layered-capture-controls.md)
- Related session: [2026-05-08 Session 005](../04_Sessions/2026-05-08_session-005.md)

## Goal
Restore the preferred Record bottom layout while making the root tab capsule larger and closer to full screen width.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/CaptureInputBarView.swift`
- `Docs/03_Decisions/ADR-020-assistant-as-composer-mode.md`
- `Docs/03_Decisions/ADR-021-preserve-layered-capture-controls.md`
- `Docs/04_Sessions/2026-05-08_session-005.md`
- `Docs/05_Changes/Change-240-restore-layered-record-controls.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Restored the `surfaceSwitcher` in `RecordFeedScreen.bottomInsetView`.
- Removed the inline `助手` button from `CaptureInputBarView`.
- Kept the larger mic/input/send controls introduced in the previous pass.
- Expanded the app-level `RootTabBar` by removing its fixed max width and reducing horizontal padding.
- Superseded ADR-020 with ADR-021.

## User-visible impact
- The Record screen bottom returns to the familiar three-layer structure.
- The root navigation capsule should feel larger, less cramped, and closer to full width.

## Verification
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -configuration Debug -destination 'generic/platform=iOS Simulator' build` passed.

## Manual Verification
- Open Record tab and check the three bottom layers.
- Switch between `记录` and `助手`.
- Send a normal record and an assistant message.
- Start recording and open the keyboard.
- Check Pro Max and smaller devices for crowding.

## Rollback
- Revert the final commit. No data migration or backend change is involved.

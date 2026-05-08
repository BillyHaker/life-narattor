# Change 241 - Record Bottom Tab Avoidance

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Record UX/Bottom Layout
- Status: Done
- Related ADR: [ADR-021](../03_Decisions/ADR-021-preserve-layered-capture-controls.md)
- Related session: [2026-05-08 Session 006](../04_Sessions/2026-05-08_session-006.md)

## Goal
Prevent the Record input row from being covered by the app-level root tab bar.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-05-08_session-006.md`
- `Docs/05_Changes/Change-241-record-bottom-tab-avoidance.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Added `rootTabBarAvoidanceHeight` to `RecordFeedScreen`.
- Applied the avoidance height as bottom padding to the Record screen bottom inset.
- Kept the preferred three-layer bottom UI and wider root tab behavior unchanged.

## User-visible impact
- The `麦克风 / 输入栏 / 发送` row should now be visible above the root tab bar.
- The `记录 / 助手` switch should no longer appear pressed behind the app-level navigation capsule.

## Verification
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -configuration Debug -destination 'generic/platform=iOS Simulator' build` passed.

## Manual Verification
- Open Record tab and check all three bottom layers.
- Switch between Record and Assistant.
- Start recording and check the recording chip is not covered.
- Open the keyboard and check the bottom controls.

## Rollback
- Revert the final commit. No data migration or backend change is involved.

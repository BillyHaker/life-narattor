# Change 242 - Bottom Navigation Position Refinement

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Record UX/Bottom Navigation
- Status: Done
- Related ADR: [ADR-021](../03_Decisions/ADR-021-preserve-layered-capture-controls.md)
- Related session: [2026-05-08 Session 007](../04_Sessions/2026-05-08_session-007.md)

## Goal
Make the root tab bar feel more Apple-like by moving it closer to the bottom and making the capsule slightly slimmer.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-05-08_session-007.md`
- `Docs/05_Changes/Change-242-bottom-navigation-position-refinement.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Reduced Record screen bottom avoidance from 112 to 96.
- Reduced root tab item height from 66 to 60.
- Reduced root tab internal padding from 9 to 7.
- Reduced root tab top/bottom padding from 8/12 to 6/4.

## User-visible impact
- The root tab bar should sit closer to the bottom and feel less like a floating block.
- The tab bar should remain wide and comfortable, but slightly less thick.

## Verification
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -configuration Debug -destination 'generic/platform=iOS Simulator' build` passed.

## Manual Verification
- Check Record screen bottom spacing on Pro Max.
- Confirm input row remains visible above the root tab.
- Confirm Home Indicator area does not feel cramped.

## Rollback
- Revert the final commit. No data migration or backend change is involved.

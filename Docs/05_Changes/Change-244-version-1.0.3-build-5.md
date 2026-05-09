# Change 244 - Version 1.0.3 Build 5

## Metadata
- Date: 2026-05-09
- Owner: Codex
- Scope: Release/iOS/App Store
- Status: Done
- Related session: [2026-05-09 Session 002](../04_Sessions/2026-05-09_session-002.md)

## Goal
Bump the app version for the next App Store update.

## Implementation
- Set `MARKETING_VERSION = 1.0.3`.
- Set `CURRENT_PROJECT_VERSION = 5`.
- Created local archive `build/archives/LifeNarrator-1.0.3-5-20260509.xcarchive`.

## User-visible Impact
- This release packages recent fixes, including bottom navigation spacing and conservative atomization causality handling.

## Verification
- Build settings confirmed `1.0.3 (5)`.
- Debug build passed.
- Release archive passed.
- Archive metadata confirmed `1.0.3` and `5`.

## App Store Connect Notes
- Create/select version `1.0.3`.
- Select uploaded build `5`.
- Suggested release notes: `优化底部导航显示；改进记录拆分准确性，减少 AI 对记录内容作出过度因果推断；修复若干体验细节。`

## Rollback
- Revert this commit to return to `1.0.2 (4)`.

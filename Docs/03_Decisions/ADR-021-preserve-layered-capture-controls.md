# ADR-021 - Preserve Layered Capture Controls

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Record UX
- Status: Accepted
- Related session: [2026-05-08 Session 005](../04_Sessions/2026-05-08_session-005.md)
- Related change: [Change 240](../05_Changes/Change-240-restore-layered-record-controls.md)

## Context
A previous iteration moved Assistant into the composer as an inline mode button to reduce bottom crowding. In real UI review, this weakened the original product rhythm and led to the input area being less legible. The user preferred the earlier three-layer structure: mode switch, input row, and app-level tab bar.

The remaining problem is not the existence of three layers, but that the app-level tab capsule was too small and floating instead of comfortably spanning the available width.

## Alternatives
- Keep Assistant as an inline composer mode.
- Restore the original three-layer structure and only enlarge the app-level tab bar.
- Remove Assistant from the Record surface entirely.

## Decision
Preserve the three-layer Record bottom UI:
1. `记录 / 助手`
2. `麦克风 / 输入栏 / 发送`
3. `记录 / 时间线 / AI 回顾`

Make the app-level tab bar larger and closer to full width rather than changing the interaction model.

## Rationale
- The explicit `记录 / 助手` switch is understandable and matches the user's preferred mental model.
- The composer stays focused on capture, without mixing mode switching into the input row.
- The app-level tab remains visually important enough for navigation by using a wider capsule and larger hit targets.

## Consequences
- The bottom area keeps three layers, so spacing must be watched on small screens and keyboard states.
- Future refinements should focus on sizing, spacing, and safe-area behavior before changing the interaction model.

## Validation
- Build must pass.
- Manual verification must confirm all three layers are visible and the root tab is wider.

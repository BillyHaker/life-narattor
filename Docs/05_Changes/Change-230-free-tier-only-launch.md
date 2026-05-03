# Change 230 - Free Tier Only Launch

## Metadata
- Date: 2026-05-03
- Owner: Codex
- Scope: Product/Backend/UX
- Status: Done
- Related ADR: [ADR-016](../03_Decisions/ADR-016-free-tier-only-launch.md)

## Goal
Make the current public version free-tier-only while preserving backend cost control through monthly AI credits.

## Files Changed
- `server/usage_limits.js`
- `server/.env.example`
- `server/README.md`
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/03_Decisions/ADR-016-free-tier-only-launch.md`
- `Docs/04_Sessions/2026-05-03_session-002.md`
- `Docs/05_Changes/Change-230-free-tier-only-launch.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Backend default public tier now falls back to `free` instead of `trial`.
- `.env.example` now sets `USAGE_DEFAULT_TIER=free`.
- Backend README now describes trial/daily/deep as internal overrides, not active paid subscription plans.
- Settings now says the current plan is `免费版`, AI has `每月免费额度`, and paid subscriptions are not currently open.
- Free AI quota exhaustion now shows friendly app copy instead of raw HTTP 402 wording for key record/transcription flows.

## User-visible impact
- Users see one simple free plan in Settings.
- Users are told that AI has a monthly free quota and restores next month after exhaustion.
- No visible copy implies that paid subscription is currently available.

## Verification
- `node --check server/usage_limits.js && node --check server/server.js` passed.
- Temporary backend usage-store smoke test confirmed default `free` tier and 300-credit exhaustion behavior.
- `git diff --check` passed.
- Xcode MCP `BuildProject` passed for `windowtab1`.
- App and server search found no stale `7 天试用`, `免费体验`, `管理订阅`, `¥8`, or `¥16` copy.

## Manual Verification
- On deployed backend, confirm new public user IDs resolve to `free` in admin.
- Trigger free quota exhaustion in staging and confirm the app shows the friendly quota message.
- Open Settings and confirm it communicates free-tier-only behavior.

## Rollback
- Revert this commit or set `USAGE_DEFAULT_TIER=trial` in the backend environment to re-enable automatic trial behavior without redeploying code.

# Change-220: Backend Usage Tiers

## Summary
Added backend usage tiers and admin visibility so public App Store users can have constrained free AI usage while reviewers, testers, and future paid users can receive higher quotas.

## Files Changed
- `server/usage_limits.js`
- `server/server.js`
- `server/.env.example`
- `server/README.md`
- `Docs/04_Sessions/2026-05-02_session-001.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Behavior
- Public users default to `free` usage limits.
- Known user ids can be promoted to `pro` or `reviewer` through environment variables.
- Quotas can be tuned through `USAGE_LIMIT_OVERRIDES` without changing code.
- Usage storage can be moved to a persistent path through `USAGE_STORE_PATH`.
- Admin pages now expose tier, model/provider, quota hits, and estimated input tokens.
- The iOS client API contract is unchanged.

## Verification
- Node syntax checks passed.
- Local backend quota smoke tests passed for `free` and `pro` tiers.
- Admin dashboard smoke test passed.
- Debug simulator build passed.
- Full `xcodebuild test` passed on iPhone 17 Pro Max simulator.

## Manual Verification Backlog
- Added `VRF-033` for production deployment quota and admin usage validation.

## Rollback Notes
- Revert this change to restore the previous single quota behavior. Existing usage JSON files are append-only and can remain in place; older code will ignore tier metadata in events.

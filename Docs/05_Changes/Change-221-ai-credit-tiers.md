# Change-221: AI Credit Tiers

## Summary
Changed backend usage control to a unified AI credit model for the planned 7-day trial, free tier, ¥8 daily tier, and ¥16 deep tier.

## Files Changed
- `server/usage_limits.js`
- `server/server.js`
- `server/.env.example`
- `server/README.md`
- `Docs/04_Sessions/2026-05-02_session-002.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Behavior
- New public users default to a 7-day `trial` tier with 700 AI credits.
- Trial credits use a fixed trial cycle and do not reset when the calendar month changes.
- Trial users automatically fall back to `free` after the trial window ends.
- Free users receive 300 credits per month.
- `daily` users receive 1500 credits per month and map to the planned ¥8/month tier.
- `deep` users receive 4500 credits per month and map to the planned ¥16/month tier.
- `reviewer` users receive a high review/test allowance.
- AI credit exhaustion returns HTTP 402 with `ai_credit_exhausted` instead of retry-style rate limiting.
- Admin usage views now show credit usage, remaining credits, tier, trial state, and per-request credit cost.

## Verification
- Node syntax checks passed.
- Local backend smoke tests passed for free/daily/deep tier exhaustion.
- Transcription credit preflight test passed.
- Trial fixed-cycle test passed.
- Admin dashboard smoke test passed.
- Debug simulator build passed.
- Full `xcodebuild test` passed on iPhone 17 Pro Max simulator.

## Manual Verification Backlog
- Added `VRF-034` for production trial/free/daily/deep credit rollout and StoreKit mapping validation.

## Rollback Notes
- Revert this change to restore per-feature daily quotas.
- Existing usage events can remain; old code ignores unknown credit metadata.

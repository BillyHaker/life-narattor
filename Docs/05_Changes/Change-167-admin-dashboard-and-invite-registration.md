# Change-167 Admin Dashboard and Invite Registration

## Summary
Added a lightweight beta admin website with usage visualization, invite management, and beta registration.

## Files Changed
- `server/server.js`
- `server/beta_user_store.js`
- `server/usage_limits.js`
- `server/invite_store.js`
- `Docs/04_Sessions/2026-03-22_session-001.md`
- `Docs/05_Changes/Change-167-admin-dashboard-and-invite-registration.md`

## Key Points
- Added HTML admin pages for dashboard, user list, user detail, and invite management.
- Added invite generation, recording, resend, and status tracking.
- Added beta registration by invite code, returning a stable backend `user_id`.
- Added dashboard usage summaries and per-user usage views from the existing quota/usage store.
- Added optional invite email delivery via Resend when backend mail settings are configured.

## Verification
- `node --check server/server.js`
- `node --check server/invite_store.js`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`
- Localhost smoke test for `/admin`, `/admin/invites`, and `/v1/beta/register`

## Rollback Notes
- Revert `server/server.js`, `server/beta_user_store.js`, and `server/usage_limits.js`, and delete `server/invite_store.js`.
- No Core Data migration or destructive rewrite is involved.

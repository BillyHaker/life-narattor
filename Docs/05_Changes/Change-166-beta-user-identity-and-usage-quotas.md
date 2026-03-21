# Change-166 Beta User Identity and Usage Quotas

## Summary
Added a first-pass beta-user identity and daily-usage quota skeleton across the backend proxy and iOS backend client path.

## Files Changed
- `server/server.js`
- `server/beta_user_store.js`
- `server/usage_limits.js`
- `Life Narattor/AI/AIService.swift`
- `Docs/04_Sessions/2026-03-21_session-001.md`
- `Docs/05_Changes/Change-166-beta-user-identity-and-usage-quotas.md`

## Key Points
- Introduced a backend-recognized beta user identity via `X-User-Id` rather than anonymous fallback.
- Added file-backed beta-user presence tracking and daily usage accounting by request type.
- Added request-type daily quotas and structured `quota_exceeded` responses.
- iOS backend requests now send a stable locally persisted beta user identifier.
- Transcription requests now send estimated audio duration so the backend can budget transcription usage in seconds rather than just request count.

## Verification
- `node --check server/server.js`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`

## Rollback Notes
- Remove `server/beta_user_store.js` and `server/usage_limits.js`, then revert the server and AIService header changes.
- No schema migration or destructive data rewrite is involved.

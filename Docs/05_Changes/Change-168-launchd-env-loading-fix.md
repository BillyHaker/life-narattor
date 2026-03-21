# Change-168 Launchd Env Loading Fix

## Summary
Fixed local backend launchd startup so environment variables are injected into the plist at install time instead of reading `.env` from the Desktop workspace at runtime.

## Files Changed
- `server/manage_launchd_proxy.sh`
- `Docs/04_Sessions/2026-03-22_session-001.md`
- `Docs/05_Changes/Change-168-launchd-env-loading-fix.md`

## Key Points
- Launchd no longer depends on runtime `source .env`, which was failing because the agent could not safely read the Desktop-based `.env` file.
- The generated plist now runs `node server.js` directly and carries required environment values in `EnvironmentVariables`.
- Reinstall now truncates old launchd logs so diagnostics reflect the current run instead of stale errors.

## Verification
- `./manage_launchd_proxy.sh install`
- `./manage_launchd_proxy.sh status`
- `./manage_launchd_proxy.sh logs`
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' build`

## Rollback Notes
- Revert `server/manage_launchd_proxy.sh` and remove the new change log entry.
- No app schema or user data is affected.

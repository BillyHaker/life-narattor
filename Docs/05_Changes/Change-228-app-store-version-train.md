# Change 228 - App Store Version Train Fix

## Goal
Resolve App Store upload rejection caused by submitting another build under the closed `1.0` pre-release train.

## Files Changed
- `Life Narattor.xcodeproj/project.pbxproj`
- `Docs/04_Sessions/2026-05-02_session-006.md`
- `Docs/05_Changes/Change-228-app-store-version-train.md`

## Implementation
- Updated `MARKETING_VERSION` from `1.0` to `1.0.1` for the app and test targets.
- Updated `CURRENT_PROJECT_VERSION` from `1` to `3` for the app and test targets.

## Verification
- Xcode MCP `BuildProject` passed for `windowtab1`.
- `plutil -lint "Life Narattor/AppConfig.plist"` passed.
- `git diff --check` passed.

## Manual Verification
- Archive and upload `1.0.1 (3)` in Xcode Organizer.
- Confirm App Store Connect accepts the new build.

## Rollback
- Revert this commit or restore the version/build settings manually. This rollback should not be used for App Store submission because `1.0` is closed.

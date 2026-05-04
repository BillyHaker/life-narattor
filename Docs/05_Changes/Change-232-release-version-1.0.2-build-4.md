# Change 232 - Release Version 1.0.2 Build 4

## Metadata
- Date: 2026-05-04
- Owner: Codex
- Scope: Release/iOS
- Status: Done
- Related ADR: None

## Goal
Prepare an App Store upload for version `1.0.2` with build number `4`.

## Files Changed
- `Life Narattor.xcodeproj/project.pbxproj`
- `Docs/04_Sessions/2026-05-04_session-001.md`
- `Docs/05_Changes/Change-232-release-version-1.0.2-build-4.md`

## Implementation
- Updated `CURRENT_PROJECT_VERSION` from `3` to `4` across app, unit test, and UI test build configurations.
- Kept `MARKETING_VERSION` at `1.0.2` across app, unit test, and UI test build configurations.

## User-visible impact
- The next uploaded build should appear in App Store Connect as version `1.0.2` build `4`.

## Verification
- `xcodebuild -showBuildSettings` confirmed `MARKETING_VERSION = 1.0.2`, `CURRENT_PROJECT_VERSION = 4`, and bundle id `com.jintaoha.Life-Narattor`.
- `git diff --check` passed.
- Xcode MCP `BuildProject` passed.

## App Store Connect Review
- Create/select version `1.0.2`.
- Select build `4` once App Store Connect finishes processing it.
- Review release notes, App Privacy, iCloud/AI reviewer notes, and screenshots if the uploaded binary contains the recent iCloud/onboarding/AI backend changes.

## Rollback
- Revert this commit or change `CURRENT_PROJECT_VERSION` back to `3` if build `4` should not be used.

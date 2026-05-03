# Change 231 - iCloud Private Sync Foundation

## Metadata
- Date: 2026-05-03
- Owner: Codex
- Scope: iOS/Data/Privacy
- Status: Done
- Related ADR: [ADR-017](../03_Decisions/ADR-017-icloud-private-sync.md)

## Goal
Use the user's Apple iCloud private database to preserve and sync Life Narrator text/structured data while keeping the app local-first and avoiding a custom account system for this launch stage.

## Files Changed
- `Life Narattor/Data/PersistenceController.swift`
- `Life Narattor/Life_Narattor.entitlements`
- `Life Narattor.xcodeproj/project.pbxproj`
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `site/index.html`
- `site/privacy/index.html`
- `Docs/01_Product/Identity_Privacy_API_Export_Design.md`
- `Docs/03_Decisions/ADR-017-icloud-private-sync.md`
- `Docs/04_Sessions/2026-05-03_session-003.md`
- `Docs/05_Changes/Change-231-icloud-private-sync.md`
- `Docs/06_Testing/App-Store-Submission-Copy.md`
- `Docs/06_Testing/Beta-Preflight-Checklist.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Replaced `NSPersistentContainer` with `NSPersistentCloudKitContainer`.
- Configured the private CloudKit container identifier `iCloud.com.jintaoha.Life-Narattor`.
- Enabled persistent history tracking and remote change notifications.
- Added app entitlements for iCloud + CloudKit and connected them to Debug and Release builds.
- Removed destructive persistent-store fallback so load/migration failures cannot silently delete user data.
- Added CloudKit-compatible default values for non-optional programmatic Core Data attributes.
- Mirrored the backend user id to iCloud KVS for reinstall continuity.
- Updated in-app and public privacy copy to explain iCloud private sync and the original-audio limitation.

## User-visible impact
- Settings now shows iCloud sync status and explains that text/structured data can sync through the user's iCloud private database.
- First-launch privacy copy now tells users that local-first data may also use their iCloud private sync.
- Privacy policy and App Store review copy are aligned with the new storage behavior.

## Verification
- `plutil -lint 'Life Narattor/Life_Narattor.entitlements' 'Life Narattor/AppConfig.plist'` passed.
- Xcode MCP `BuildProject` passed for `windowtab1`.
- Xcode MCP `ExecuteSnippet` Core Data smoke produced `cloudkit-smoke-count=1`.
- Release simulator `xcodebuild` passed.
- `git diff --check` passed.

## Manual Verification
- Confirm iCloud + CloudKit capability and container are enabled in Apple Developer/Xcode.
- On signed iCloud-enabled devices, verify create/reinstall/second-device restore for records, transcriptions, organized results, atomization, and tags.
- Confirm original audio is not represented as cross-device recoverable.
- Confirm Settings iCloud status copy is accurate when iCloud is signed in or unavailable.

## Rollback
- Revert this commit to return to local-only persistence and previous privacy copy.
- If only entitlement signing blocks Archive, remove the entitlement build setting and CloudKit store options while keeping the non-destructive store-load fix.

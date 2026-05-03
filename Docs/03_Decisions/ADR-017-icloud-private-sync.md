# ADR-017 - iCloud Private Sync Foundation

## Metadata
- Date: 2026-05-03
- Owner: Codex
- Scope: iOS/Data/Privacy
- Status: Accepted
- Related skills: None

## Context
Life Narrator started as a local-first app. After public release, users need data continuity across app reinstall, app upgrade, and eventually multiple Apple devices. The app also needs to keep its privacy promise precise: journal content should not become a Life Narrator server-side data store, while AI features may still send selected text to the configured AI service with user consent.

## Alternatives
- Keep all data local only. This is simplest and strongest for privacy, but deleting the app can delete user records and creates a bad long-term trust problem.
- Build a custom account and server database now. This gives admin recovery and analytics control, but introduces account complexity, backend security risk, and a larger privacy surface too early.
- Use Apple's iCloud private database through Core Data + CloudKit for user records, while keeping the app local-first and deferring a custom account layer.

## Decision
Use `NSPersistentCloudKitContainer` with the private CloudKit container `iCloud.com.jintaoha.Life-Narattor` for the Core Data store. Text records, transcriptions, organized records, atomized structure, and tags sync through the user's Apple iCloud private database. The app's backend user identifier is also mirrored to `NSUbiquitousKeyValueStore` so reinstalling can preserve the same AI quota identity when iCloud is available.

Original audio files are not included in the current sync commitment. They remain local-first and are not guaranteed to recover across devices or reinstall in this version.

## Rationale
- iCloud private database matches the product's low-pressure, no-new-account direction.
- Users keep ownership through Apple ID/iCloud without giving Life Narrator a full content database.
- Core Data + CloudKit is the smallest change that can preserve existing local data behavior while adding restore/sync potential.
- KVS identity sync reduces accidental quota reset after reinstall without requiring a custom login.

## Consequences
- Xcode/App Store signing must enable iCloud + CloudKit for the app id and container `iCloud.com.jintaoha.Life-Narattor`.
- CloudKit schema behavior must be validated on signed devices with iCloud enabled; simulator builds cannot fully prove real iCloud sync.
- The public privacy copy must say that structured/text data may sync to the user's iCloud private database, while Life Narrator servers do not store a complete content copy.
- The app must avoid destructive persistent-store recovery because deleting a local store on migration/load failure would be unacceptable once iCloud sync is involved.

## Validation
- Debug build succeeds.
- Release simulator build succeeds with the entitlement file included.
- In-memory Core Data smoke test can create and fetch a `CaptureEntity` using the updated container.
- Manual signed-device validation must confirm: create record on device A, wait for CloudKit sync, install/sign in on device B or reinstall, confirm text/structured record data appears.

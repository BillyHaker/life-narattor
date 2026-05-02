# Change-222: App Settings Screen

## Summary
Added a user-facing settings page from the Record page header for AI usage, privacy, voice permissions, support links, and app version information.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `Docs/04_Sessions/2026-05-02_session-003.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Behavior
- Record page now shows a small gear button beside today's date.
- Tapping the gear opens a settings sheet.
- Settings includes:
  - AI usage and quota/subscription explanatory copy.
  - Local-first storage and third-party AI processing disclosure.
  - Voice transcription permission guidance and a system settings shortcut.
  - Privacy policy and support links.
  - App version/build display.
- DevTools remain hidden from the public settings surface.

## Verification
- Debug simulator build passed.
- Full `xcodebuild test` passed on iPhone 17 Pro Max simulator.

## Manual Verification Backlog
- Added `VRF-035` for on-device settings entry, layout, links, and permission shortcut validation.

## Rollback Notes
- Revert this change to remove the settings page and the Record page gear entry.

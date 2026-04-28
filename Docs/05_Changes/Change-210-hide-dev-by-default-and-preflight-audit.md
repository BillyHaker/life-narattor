# Change 210 — Hide Dev by default and preflight audit

## Summary
Hid the developer tools tab by default even in Debug builds, kept Release/TestFlight compile-time protection, and expanded the beta submission checklist with final review-preflight items.

## Changes
- Added `FeatureFlags.isDeveloperMenuVisible` as an internal developer menu gate.
- In Release builds, the developer menu flag always returns `false`.
- Updated root tab construction so `DevToolsRootView` only appears under both `#if DEBUG` and the explicit developer menu flag.
- Updated beta launch/preflight docs to require Release/Archive visual verification that `Dev` is absent.
- Added checklist reminders for App Store Connect build selection, privacy/support URLs, App Privacy consistency, review notes, backend health, invite/quota paths, and final smoke testing.
- Added a manual verification backlog item for Release/Archive no-Dev validation.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/DevTools/FeatureFlags.swift`
- `Docs/06_Testing/Beta-Preflight-Checklist.md`
- `Docs/06_Testing/Beta-Launch-Checklist.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- Release build settings check found no active Release `DEBUG` condition output.
- Static scan confirmed the Dev tab is behind both Debug compilation and `isDeveloperMenuVisible`.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed on iPhone 17 Pro Max simulator.
- Remaining manual verification: install the final Release/Archive/TestFlight build and visually confirm bottom navigation does not show `Dev`.

## Rollback
Revert this change commit. That restores the previous Debug-visible developer tab behavior while keeping the existing compile-time Release/TestFlight exclusion if the `#if DEBUG` guard remains.

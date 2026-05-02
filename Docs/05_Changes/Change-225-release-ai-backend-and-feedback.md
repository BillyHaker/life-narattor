# Change-225: Release AI Backend and Feedback Flow

## Summary
Added Release-safe AI backend configuration and an in-app feedback flow backed by a lightweight server endpoint.

## Files Changed
- `Life Narattor.xcodeproj/project.pbxproj`
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/AppConfig.plist`
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `Life Narattor/Screens/FeedbackScreen.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `server/.env.example`
- `server/README.md`
- `server/Dockerfile`
- `server/feedback_store.js`
- `server/package.json`
- `server/server.js`
- `site/support/index.html`
- `Docs/04_Sessions/2026-05-02_session-006.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Behavior
- Release/App Store builds can now read a backend base URL from bundled config instead of relying on unavailable local debug environment variables.
- Missing AI configuration no longer leaks internal wording to users; it presents as a temporary AI service availability problem.
- Settings now includes a `反馈问题` entry.
- AI split failure states include a direct feedback path.
- Feedback accepts a short message, optional contact, optional screenshot, and app/device metadata.
- Backend admins can inspect feedback at `/admin/feedback`.

## Verification
- JS syntax checks passed.
- Plist lint passed.
- Local backend feedback smoke test passed.
- Debug simulator build passed.
- Full Xcode test suite passed.
- Release simulator build passed.
- Confirmed bundled `AppConfig.plist` is present in app bundles.

## Manual Verification Backlog
- Added `VRF-038` for public backend deployment, Release URL configuration, in-app AI path verification, and feedback admin review.

## Rollback Notes
- Revert this change to remove the feedback flow and restore the previous local/debug-only AI configuration behavior.

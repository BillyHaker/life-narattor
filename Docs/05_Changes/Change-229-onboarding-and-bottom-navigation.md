# Change 229 - Onboarding and Bottom Navigation

## Metadata
- Date: 2026-05-03
- Owner: Codex
- Scope: UX/UI
- Status: Done
- Related ADR: [ADR-015](../03_Decisions/ADR-015-onboarding-and-custom-bottom-navigation.md)

## Goal
Make the App Store build easier to start using and make the bottom navigation feel less small and cramped on large iPhones.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Screens/OnboardingGuideScreen.swift`
- `Docs/03_Decisions/ADR-015-onboarding-and-custom-bottom-navigation.md`
- `Docs/04_Sessions/2026-05-03_session-001.md`
- `Docs/05_Changes/Change-229-onboarding-and-bottom-navigation.md`

## Implementation
- Added a first-run product guide shown after privacy consent and before the main app.
- Explained three core flows: quick recording and assistant整理, Timeline AI review, and AI Review questions.
- Added a Settings row to replay the guide.
- Replaced the root native `TabView` navigation with a larger custom three-item bottom bar.
- Removed the production root Dev tab exposure by only showing Record, Timeline, and AI Review.
- Lazy-load root tab content to avoid hidden Timeline or AI Review work before the user opens those tabs.

## User-visible impact
- New users get a concise introduction instead of landing cold on the record page.
- The bottom toolbar is larger, clearer, and less crowded on Pro Max devices.
- Production users no longer see a Dev tab in the main navigation.

## Verification
- Xcode MCP `BuildProject` passed for `windowtab1`.
- Xcode MCP `RenderPreview` passed for `Life Narattor/Screens/OnboardingGuideScreen.swift`.
- `git diff --check` passed.
- `rg` confirmed no root `.tabItem` usage remains in app code.

## Manual Verification
- Reset onboarding state and confirm first-run guide appears after privacy consent.
- Complete and skip onboarding paths; both should enter the main app.
- Open Settings and replay the guide.
- Check bottom navigation hit targets and spacing on iPhone 17 Pro Max.
- Confirm selecting Timeline and AI Review works and visited tabs retain state.

## Rollback
- Revert this commit to restore the prior native `TabView` and remove onboarding.

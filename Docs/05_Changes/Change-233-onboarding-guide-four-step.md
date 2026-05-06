# Change 233 - Four-Step Onboarding Guide

## Metadata
- Date: 2026-05-06
- Owner: Codex
- Scope: iOS/Onboarding/UX
- Status: Done
- Related ADR: [ADR-015](../03_Decisions/ADR-015-onboarding-and-custom-bottom-navigation.md)

## Goal
Make the first-run guide more actionable and easier for new users to understand before they enter the app.

## Files Changed
- `Life Narattor/Screens/OnboardingGuideScreen.swift`
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `Docs/04_Sessions/2026-05-06_session-001.md`
- `Docs/05_Changes/Change-233-onboarding-guide-four-step.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Replaced the previous three-page explanation with four focused onboarding steps.
- Added a visible action pill to each page so every screen answers “what should I do here?”
- Clarified that records can be short, assistant conversations can become drafts, Timeline summarizes ended periods, and AI Review can answer open-ended review questions.
- Updated Settings replay copy to `重新看使用引导` and `4 步`.

## User-visible impact
- First-time users get a clearer, lower-pressure introduction.
- The final onboarding action now points directly toward recording with `开始记录`.
- Existing users can replay the updated guide from Settings.

## Verification
- Xcode MCP `RenderPreview` passed for the onboarding screen.
- Xcode MCP `BuildProject` passed.
- `git diff --check` passed.

## Manual Verification
- Fresh install / reset product-guide state: privacy consent -> four-step guide -> Record tab.
- Skip path: `跳过，直接进入` enters the Record tab.
- Replay path: Settings -> `重新看使用引导` opens the guide.
- Small-device visual check: no overlap between card content and bottom controls.

## Rollback
- Revert this commit to restore the previous onboarding guide.

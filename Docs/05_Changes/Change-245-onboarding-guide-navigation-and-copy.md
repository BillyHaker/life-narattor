---
date: 2026-05-11
owner: Codex
scope: iOS/Onboarding/UX
status: Done
related_session: ../04_Sessions/2026-05-11_session-001.md
---

# Change 245 - Onboarding Guide Navigation and Copy

## What Changed
- Replaced the product onboarding guide's `TabView(selection:)` page switching with explicit current-page rendering driven by `pageIndex`.
- Kept the existing page dots and primary/secondary navigation controls.
- Added a lightweight horizontal drag gesture so users can still swipe between guide pages.
- Revised onboarding labels from sequential `第一步 / 第二步 / 第三步` to parallel product concepts: `直接记录 / 助手整理 / 回看线索`.
- Updated the header copy to say direct recording and assistant use are parallel choices with no fixed order.

## Files Changed
- `Life Narattor/Screens/OnboardingGuideScreen.swift`
- `Docs/04_Sessions/2026-05-11_session-001.md`
- `Docs/05_Changes/Change-245-onboarding-guide-navigation-and-copy.md`

## User-Visible Impact
- Tapping `继续` on the onboarding guide should reliably advance to the next page.
- The guide no longer implies that direct recording must happen before assistant-assisted recording.
- New users see a clearer model: record directly when clear, use the assistant when messy, then review later.

## Verification
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build` passed.
- `xcodebuild -project 'Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test` passed.
- Existing warnings remain unrelated to this change:
  - `VoiceTranscriptionService.swift` cancellation handler warnings.
  - AppIntents metadata extraction skipped because no AppIntents dependency exists.

## Manual Verification Steps
1. Reset or clear `app.hasSeenProductGuide`.
2. Launch the app after privacy consent.
3. On the product guide, tap `继续`; expected: page changes from `直接记录` to `助手整理`.
4. Tap `继续` again; expected: page changes to `回看线索`.
5. On the last page, tap `开始记一句`; expected: app enters the main record screen.
6. Replay the guide from Settings and confirm `先进入看看` immediately enters the app.

## Rollback Notes
- Revert this change to restore the prior `TabView(selection:)` onboarding implementation and old sequential labels.
- No data model, API, privacy, or persistence changes are involved.

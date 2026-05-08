# Change 238 - Purposeful Onboarding Flow

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Onboarding/UX
- Status: Done
- Related ADR: [ADR-019](../03_Decisions/ADR-019-purposeful-onboarding-flow.md)
- Related session: [2026-05-08 Session 003](../04_Sessions/2026-05-08_session-003.md)

## Goal
Make onboarding feel like one clear starting path instead of a collection of fragmented feature notes.

## Files Changed
- `Life Narattor/Screens/OnboardingGuideScreen.swift`
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/03_Decisions/ADR-019-purposeful-onboarding-flow.md`
- `Docs/04_Sessions/2026-05-08_session-003.md`
- `Docs/05_Changes/Change-238-purposeful-onboarding-flow.md`

## Implementation
- Changed onboarding from four feature pages to three usage-path pages.
- Removed checklist-style per-page bullet fragments.
- Added a focused guide block and one example block per page.
- Updated the final CTA from `开始记录` to `开始记一句`.
- Updated skip copy from `跳过，直接进入` to `先进入看看`.
- Updated Settings replay value to `3 步`.

## User-visible impact
- First-time users should understand that they can start with a short, low-pressure record.
- The assistant is framed as an alternative capture path when thoughts are unclear.
- Timeline and AI Review are framed as later reflection tools based on accumulated records.

## Verification
- Debug simulator build passed.
- Full Xcode test suite passed on iPhone 17 Pro Max simulator.

## Manual Verification
- Reset first-run product guide state and verify the three-page flow after privacy consent.
- Complete and skip onboarding; both should enter the app.
- Replay from Settings and verify the label says `3 步`.
- Check that page text does not overflow on small devices.

## Rollback
- Revert the final commit.
- No data migration or backend change is involved.

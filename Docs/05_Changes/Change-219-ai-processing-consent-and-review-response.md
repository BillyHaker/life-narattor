# Change-219: AI Processing Consent and Review Response

## Summary
Added an explicit in-app AI data processing consent gate and updated public review/privacy materials for App Review Guidelines 5.1.1(i) and 5.1.2(i).

## Files Changed
- `Life Narattor/ContentView.swift`
- `site/privacy/index.html`
- `Docs/06_Testing/Beta-Review-Notes.md`
- `Docs/06_Testing/App-Review-Privacy-Response.md`
- `Docs/04_Sessions/2026-04-29_session-001.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Behavior
- Users can only enter the app after both the old privacy intro flag and the new AI processing consent flag are true.
- Fresh installs see the new `隐私与 AI 处理说明` screen before any AI-capable surface is available.
- Existing installs that previously passed the older intro but do not have the new AI consent flag will see the updated consent screen after upgrading.
- The disclosure identifies data categories, third-party AI providers, purpose, and key privacy boundaries.

## Verification
- `git diff --check` passed.
- Debug simulator build passed.
- Release device build with `CODE_SIGNING_ALLOWED=NO` passed.
- Full `xcodebuild test` passed on iPhone 17 Pro Max simulator.

## Manual Verification Backlog
- Added `VRF-032` for visual first-launch and upgrade-path consent verification.

## Rollback Notes
- Remove `privacy.hasConsentedToAIProcessing` gating and restore the older `PrivacyIntroScreen` copy if this review strategy needs to be rolled back.

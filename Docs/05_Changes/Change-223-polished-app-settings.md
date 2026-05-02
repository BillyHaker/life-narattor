# Change-223: Polished App Settings

## Summary
Reworked the settings page into a finished product-style settings center with a plan card and compact grouped rows.

## Files Changed
- `Life Narattor/Screens/AppSettingsScreen.swift`
- `Docs/04_Sessions/2026-05-02_session-004.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Behavior
- Settings now opens with a `Life Narrator` plan/status card.
- AI/subscription, data/privacy, voice, and support/about are grouped into scannable setting rows.
- Future capabilities are labeled with clear statuses rather than long development copy.
- Privacy policy, support, system settings, and version information remain accessible.

## Verification
- Debug simulator build passed.
- Full `xcodebuild test` passed on iPhone 17 Pro Max simulator.

## Manual Verification Backlog
- Added `VRF-036` for product-ready settings visual hierarchy and row behavior.

## Rollback Notes
- Revert this change to restore the earlier explanatory settings screen.

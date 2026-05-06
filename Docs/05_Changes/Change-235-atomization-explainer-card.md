# Change 235 - Atomization Explainer Card

## Metadata
- Date: 2026-05-06
- Owner: Codex
- Scope: iOS/Record Detail/UX
- Status: Done
- Related ADR: None

## Goal
Help users understand how record splitting works at the moment they encounter the split tab.

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Docs/04_Sessions/2026-05-06_session-003.md`
- `Docs/05_Changes/Change-235-atomization-explainer-card.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Implementation
- Added a dismissible `AtomSplitHintCard` to the record detail `拆分` tab.
- Persisted dismissal with `app.hasSeenAtomSplitHint`.
- Used a short example to demonstrate splitting without making onboarding feel complex.

## User-visible impact
- First-time users entering the split tab see a lightweight explanation of why split fragments matter.
- The explanation does not interrupt the initial onboarding flow.

## Verification
- `git diff --check` passed.
- Xcode MCP `BuildProject` passed.

## Manual Verification
- First entry to `记录详情 -> 拆分` shows the card.
- Closing the card hides it and persists the dismissal.
- Existing split results remain visible below the card when present.

## Rollback
- Revert this commit to remove the split-tab explainer.

# Change-073 — DayDetail Source Sentence Consistency

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/DayDetail/SourceMapping
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Added narrative sentence normalization in `DayDetailScreen`:
  - normalize sentence trailing punctuation to a single `。`.
- Applied normalized sentence directly in source mappings:
  - ensures “今日叙事” and “引用来源” display the same sentence text shape.
- Switched source row IDs to deterministic values:
  - from random UUID to `captureID-index`, reducing list identity jitter during recomputation.
- Included `「」` in punctuation trimming and boundary detection.

## Files Changed
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-026.md`
- `Docs/05_Changes/Change-073-daydetail-source-sentence-consistency.md`

## Contracts/DB changes
- None.

## User-visible impact
- DayDetail narrative and source list wording are more stable and consistent.
- Re-opening/refreshing DayDetail is less likely to show source row flicker from unstable IDs.

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-daydetail-consistency/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-consistency-derived build`
   - Result: `EXIT:0`
2. Manual (deferred):
   - `VRF-001`, `VRF-002` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

# Change-070 — DayDetail Narrative Dedup And Aggregation

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/DayDetail/UI
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Upgraded local narrative generation in `DayDetailScreen`:
  - candidate captures window increased to latest 8 records.
  - added local dedup (`narrativeDedupKey`) with punctuation/space-insensitive normalization.
  - added duplicate aggregation count per narrative unit.
- Updated sentence templates:
  - duplicate mentions summarized with `(共 N 次)`.
  - reduced repetitive "在上午/在下午" wording for consecutive same-day-part records.
- Kept traceability:
  - each generated sentence still maps to a concrete `captureID` and `createdAt`.

## Files Changed
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Docs/04_Sessions/2026-03-08_session-023.md`
- `Docs/05_Changes/Change-070-daydetail-narrative-dedup-and-aggregation.md`

## Contracts/DB changes
- None.

## User-visible impact
- Day narrative is less repetitive and better summarizes repeated entries.
- Source references remain clickable and stable.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`
2. Manual:
   - Add multiple similar captures in one day.
   - Open DayDetail and verify repeated content is aggregated.
   - Check "引用来源" still opens matching capture details.

## Rollback Notes
- Revert files listed in `Files Changed`.

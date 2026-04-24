# Change-069 — DayDetail Local Narrative Generation

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/DayDetail/UI
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Replaced fixed placeholder narrative text in `DayDetailScreen` with local generated narrative:
  - Uses up to 5 most recent captures for the selected day.
  - Generates simple time-aware sentences (`上午/下午/晚上`).
  - Applies snippet normalization and truncation for readability.
- Updated source mapping:
  - `sourceMappings` now directly maps generated narrative sentence to the exact source capture ID/time.
  - Removed old placeholder sentence zip mapping behavior.
- Updated "重新生成" button to refresh from storage (`loadCaptures()`), disabled when no captures.

## Files Changed
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Docs/04_Sessions/2026-03-08_session-022.md`
- `Docs/05_Changes/Change-069-daydetail-local-narrative-generation.md`

## Contracts/DB changes
- None.

## User-visible impact
- Day detail page now shows real narrative derived from actual records, not static placeholder copy.
- "引用来源" now consistently points to real sentence-source mappings.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived build`
   - Result: `EXIT:0`
2. Manual:
   - Create multiple captures in one day.
   - Open DayDetail.
   - Verify "今日叙事" text reflects actual capture content.
   - Expand "引用来源" and tap entries to open corresponding capture detail.

## Rollback Notes
- Revert files listed in `Files Changed`.

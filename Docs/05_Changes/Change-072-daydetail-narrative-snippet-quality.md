# Change-072 — DayDetail Narrative Snippet Quality

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/DayDetail/LocalNarrative
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Improved local snippet extraction in `DayDetailScreen`:
  - prefer readable sentence segment over raw full text.
  - trim noisy leading/trailing punctuation.
  - fallback to `一段记录` for low-signal inputs.
- Added safer long-text truncation:
  - when cut point lands in a Latin word, backtrack to nearest word boundary.
  - avoids outputs like partial English word tails.

## Files Changed
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-025.md`
- `Docs/05_Changes/Change-072-daydetail-narrative-snippet-quality.md`

## Contracts/DB changes
- None.

## User-visible impact
- DayDetail “今日叙事”文案在中英混合输入下更自然，可读性更高。
- 减少异常片段（纯标点/空白）进入叙事句子。

## Verification Steps
1. Build:
   - `xcodebuild -project '/tmp/life-narrator-codex-daydetail/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-daydetail-derived build`
   - Result: `EXIT:0`
2. Manual (deferred, backlog item):
   - `VRF-001` in `Docs/VERIFICATION_BACKLOG.md`

## Rollback Notes
- Revert files listed in `Files Changed`.

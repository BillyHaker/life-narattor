# Change-055 — Source Highlight + Core Compliance Tests

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: Atomization/UI/Testing
- Related Skills: atomization, capture-ui, privacy-redaction-standard, acceptance-testing-min-bar
- Related ADRs: None
- Status: Done

## What changed
- Implemented Atom source traceability in capture detail:
  - Atom row now conditionally shows `来源` when `startChar/endChar` are valid.
  - Added source-highlight sheet rendering Clean text with highlighted range.
  - Added strict bounds check; invalid offsets show `来源数据不完整` without crash.
- Added automated tests:
  - `AIDebugRedactorTests` with 5 scenarios:
    - sk key redaction
    - Bearer token redaction
    - `api_key` JSON field redaction
    - email redaction
    - `clean_text` truncation
  - `AtomTagStoreTests`:
    - `markAsKey` persistence check
    - `deleteAtom` cascade cleanup for `AtomTagEntity`.

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Life NarattorTests/AIDebugRedactorTests.swift`
- `Life NarattorTests/AtomTagStoreTests.swift`
- `Docs/04_Sessions/2026-03-07_session-008.md`
- `Docs/05_Changes/Change-055-source-highlight-and-core-tests.md`

## Contracts/DB changes
- None.

## User-visible impact
- In `拆分` tab, users can open `来源` to visually locate atom text range in `整理后` content.
- Old/invalid offset data degrades safely (no entry point or graceful warning), no crash.

## Verification Steps
1. Build (worktree):
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `** BUILD SUCCEEDED **`
2. Unit tests:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' -derivedDataPath /tmp/life-narrator-worktree-derived test -only-testing:'Life NarattorTests'`
   - Expected: `** TEST SUCCEEDED **`
   - Observed passing tests:
     - `AIDebugRedactorTests` (5/5)
     - `AtomTagStoreTests` (2/2)

## Rollback Notes
- Revert all files listed in `Files Changed`, then rerun build/tests using the same worktree commands.

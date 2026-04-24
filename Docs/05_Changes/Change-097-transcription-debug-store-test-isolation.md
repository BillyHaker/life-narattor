# Change-097 — Transcription Debug Store Test Isolation

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Tests / Debug tooling
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 更新 `Life NarattorTests/TranscriptionDebugStoreTests.swift`
- 让每个测试使用独立的 `TranscriptionDebugStore()` 实例
- 不再共享 `TranscriptionDebugStore.shared`

## Why
- `swift-testing` 可能并行执行测试
- 共享单例会让 `lastFallbackReason`、`lastErrorCode`、`latestEvent` 在不同测试之间串状态
- 这会表现为：
  - fallback 测试读到 voice error 的结果
  - voice normalization 测试读到 ai http error 的结果

## Files Changed
- `Life NarattorTests/TranscriptionDebugStoreTests.swift`
- `Docs/04_Sessions/2026-03-14_session-001.md`
- `Docs/05_Changes/Change-097-transcription-debug-store-test-isolation.md`

## User-visible impact
- None directly. This fixes test reliability and removes false run blockers in Xcode test phase.

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Run targeted tests:
   - `xcodebuild ... test -only-testing:'Life NarattorTests/TranscriptionDebugStoreTests'`
3. If CLI test run is blocked by simulator state, rerun from Xcode after simulator reset; the code fix is test isolation, not simulator lifecycle management.

## Rollback Notes
- Revert `Life NarattorTests/TranscriptionDebugStoreTests.swift` to use `TranscriptionDebugStore.shared`.

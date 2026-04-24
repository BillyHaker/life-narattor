# Change-095 — Assist Style Tone Calibration

## Meta
- Date: 2026-03-12
- Owner: Codex (GPT-5)
- Scope: AI prompt / local fallback / assist tone
- Status: Done with known unrelated test failures

## What changed
- 收紧 `quickAck` 指令与 mock 文案，改成更短、更中性、更克制的确认语气
- 收紧 `assist` 指令，明确角色是高质量个人助手，而不是 supportive assistant / secretary / coach / teacher
- 调整本地 enrich / fallback 逻辑：
  - 默认先给判断，再给一个最小动作
  - 默认最多一个关键追问
  - 不再默认要求完整 `成功标准` 才算有效回复
  - 不再默认输出 `Why / How / 下一步` 模板
  - 过滤“一步一步来 / 复盘 / 系统方案 / 详细方案”等老师腔、教练腔片段
- 压缩 archive card 默认输出：
  - `keyPoints` 最多保留 2 条
  - `nextSteps` 默认只保留 1 条

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-12_session-001.md`
- `Docs/05_Changes/Change-095-assist-style-tone-calibration.md`

## User-visible impact
- 助手首轮回复会更像冷静、可靠、克制的个人助手。
- 简单问题默认不再被升级成教学方案或固定分析模板。
- fallback 场景下的语气会更接近主路径，而不是明显切回“教练式兜底”。

## Verification Steps
1. Build project in Xcode with `Life Narattor` scheme.
2. 在助手模式输入简单分析题，确认回复是短判断 + 一个最小动作。
3. 在助手模式输入简单记录题，确认默认优先沉淀记录，不额外展开讲解。
4. 模拟 assist 主路径失败，确认 quickAck + 本地 enrich 的 fallback 仍不出现模板腔。
5. Run all tests and note current unrelated failures in `TranscriptionDebugStoreTests`.

## Verification Result
- Build: passed
- Tests: 14 total, 12 passed, 2 failed
- Failed:
  - `TranscriptionDebugStoreTests/fallbackUpdatesSummary()`
  - `TranscriptionDebugStoreTests/voiceErrorNormalization()`

## Rollback Notes
- Revert:
  - `Life Narattor/AI/AIService.swift`
  - `server/server.js`
  - `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- Remove:
  - `Docs/04_Sessions/2026-03-12_session-001.md`
  - `Docs/05_Changes/Change-095-assist-style-tone-calibration.md`

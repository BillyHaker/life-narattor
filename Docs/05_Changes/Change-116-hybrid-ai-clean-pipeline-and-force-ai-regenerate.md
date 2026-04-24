---
date: 2026-03-14
owner: Codex
scope: AI/Text/UI
related_skills:
  - clean-defiller
status: Done
---

# Change Log

## What Changed
将记录整理升级为混合 clean 管线：默认先跑规则清理，复杂文本自动调用 AI clean；详情页“重新整理”默认强制触发 AI clean。

## Files Changed
- `Life Narattor/Text/CleanDefiller.swift`
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Data/AtomTagStore.swift`
- `server/server.js`

## User-Visible Impact
- 简单文本继续走规则清理，成本低。
- 复杂转写会自动触发 AI 整理，`整理后` 会比 `原始` 更可读。
- 详情页新增 `重新整理`，默认强制 AI 重新整理当前记录。
- 重新整理后会清除旧拆分结果，并自动重新进入拆分流程。

## Technical Summary
- `AIService` 新增 `cleanTranscript(text:forceAI:)`。
- backend 新增 `/v1/clean` 独立接口。
- 复杂度判定依据：长度、口头词密度、重复密度、无标点长句、中英混杂、规则清理后仍脏。
- 满足阈值自动走 AI；手动 `重新整理` 始终走 AI。
- AI clean 只允许：去口头词、去重复、修复断裂句、补最少标点；禁止总结和正式化改写。

## Verification Steps
1. 录一条重复较多、停顿较多的语音。
2. 等转写完成后打开详情页，对比“整理后”和“原始”。
3. 在“整理后”点击 `重新整理`。
4. 观察整理文本是否更新，并且拆分会重新生成。
5. 预期：复杂文本自动进 AI，简单文本仍走规则版。

## Rollback Notes
- 回滚 `AIService.swift` 中 `cleanTranscript(...)` 及其调用。
- 删除 `server/server.js` 的 `/v1/clean`。
- 将 `CaptureFeedViewModel.swift` 中 `scheduleClean/resolveCleanResult` 回滚到直接 `CleanDefiller.clean(...)` 即可恢复规则版行为。

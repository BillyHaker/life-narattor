---
date: 2026-03-15
owner: Codex
scope: AI/Data Model/UI
status: Done
---

# Change Log

## What Changed
在 `record_units` 中新增 `result_or_state` 层，用来保留原文中明确出现的结果、感受、状态变化与后果，避免这些信息在组装记录单元时被摘要吞掉或直接丢失。

## Files Changed
- `Life Narattor/Models/AtomizationModels.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Life Narattor/Views/CaptureDetailSheet.swift`

## User-Visible Impact
- 拆分页会额外显示“结果”区块。
- 像“感觉不错”“只能周一加班完成”这类原文明确给出的结果或状态，会更容易被保住，而不是消失或被错误并入别的摘要。

## Technical Summary
- `RecordUnitDraft` 新增 `resultOrState` / `result_or_state`。
- atomize prompt 显式要求：原文里的结果、后果、感受、状态变化不得丢失。
- app 与 backend atomize schema 同步新增 `result_or_state` 必填数组。
- 拆分页 `RecordUnitDraftRowView` 增加“结果”展示区。
- tag suggestion 输入会同时吃到 `result_or_state`，避免标签线索只依赖 summary。

## Verification Steps
1. 对包含明确感受或结果的文本重新拆分。
2. 确认拆分页出现“结果”区块。
3. 确认 `node --check` 与 `xcodebuild` 通过。

## Rollback Notes
- 回滚 `RecordUnitDraft` 的 `result_or_state` 字段与对应 prompt/schema/UI 展示即可恢复上一版结构。

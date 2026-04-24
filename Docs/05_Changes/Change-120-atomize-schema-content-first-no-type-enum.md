---
date: 2026-03-15
owner: Codex
scope: AI/Data Model
status: Done
---

# Change Log

## What Changed
将拆分链路从“typed atoms”改成“content-first units”：AI 不再被 `event/feeling/thought/action/decision/insight/question/context` 这组类型枚举强约束，先输出值得保留的记录单元，再由本地兼容层推断粗类型供现有 UI 使用。

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/Models/AtomItem.swift`
- `Life Narattor/Models/AtomizationModels.swift`
- `server/server.js`

## User-Visible Impact
- 拆分结果不再因为“先贴类型”而被迫切成大量短句。
- 当前界面仍会显示类型 icon，但这是兼容层本地推断，不再决定 AI 的拆分边界。

## Technical Summary
- `atomizeSchema()` 与 backend `/v1/atomize` schema 去掉 `type` 必填字段。
- backend atomize request body 清理旧 policy 字段，改为 `prefer_retainable_units`。
- `AtomDraft` 允许缺少 `type` 时解码成功。
- `AtomType.inferred(from:)` 提供临时的本地粗分类，维持当前列表与详情页展示稳定。

## Verification Steps
1. 运行 `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`。
2. 运行 Xcode build，确认 `AIService.swift`、`AtomizationModels.swift`、`AtomItem.swift` 联动无编译错误。
3. 对一条较长记录执行 `重新拆分`，观察结果是否更偏向“几件事”而不是“几类短句”。

## Rollback Notes
- 若要回滚，可恢复 `AIService.swift` 与 `server/server.js` 中 atomize schema 的 `type` 字段，并撤销 `AtomDraft` 的缺省解码逻辑。
- 回滚后 UI 不需要额外调整，因为当前兼容层只是附加保护，不是新主路径。

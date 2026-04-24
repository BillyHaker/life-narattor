---
date: 2026-03-15
owner: Codex
scope: AI/Data Model/UI
status: Done
---

# Change Log

## What Changed
为 `record_units` 增加了组装保底规则，重点解决两类错误：
1. 把纯情绪/状态句错误拆成新的独立事项。
2. 把主事件本身错误复写进 `result_or_state`。

## Files Changed
- `Life Narattor/Models/AtomizationModels.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`

## User-Visible Impact
- 拆分页中，像“对未完成的任务感到无奈”这类纯情绪句，会更倾向于附着到最近主事项，而不是单独形成一条新事项。
- “结果”区块会更克制，减少把主事件内容重复写一遍的情况。

## Technical Summary
- `RecordUnitDraft` 新增本地归一化能力：清洗空白、去重、过滤无效结果项。
- `AtomizeResult` 在解码后统一执行 `normalizeRecordUnits(...)`。
- 如果某条 unit 只有状态/情绪，没有自己的行为链或上下文，它会默认并入上一条主事项。
- `result_or_state` 只保留后果、结果、感受、状态变化，不再接受主事件复述。
- atomize prompt 明确补充：`summary` 一条只允许一个主事项；感受默认附着；`result_or_state` 禁止复述主事项。

## Verification Steps
1. 重新拆分包含“情绪/感受”但不应独立成事的文本。
2. 确认不会再额外出现纯情绪事项。
3. 确认“结果”区块不再明显重复 summary。
4. 确认 `node --check` 与 `xcodebuild` 通过。

## Rollback Notes
- 回滚 `AtomizationModels.swift` 中的归一化逻辑，以及 app/backend atomize prompt 的新增约束，即可恢复上一版行为。

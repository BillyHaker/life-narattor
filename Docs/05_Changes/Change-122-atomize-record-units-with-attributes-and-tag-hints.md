---
date: 2026-03-15
owner: Codex
scope: AI/Data Model
status: Done
---

# Change Log

## What Changed
将拆分输出从单一 `atoms` 提升为 `record_units`，每条单元包含 `summary + attributes + tag_hints`。第一版仍通过兼容层映射回现有 atom 列表展示，但拆分判断已经转向“值得留下的事项”而不是“最小短语”。

## Files Changed
- `Life Narattor/Models/AtomizationModels.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`

## User-Visible Impact
- AI 拆分会更偏向少拆、整块拆。
- 细节信息不再只能靠把短语单独拆出来保存，而是允许作为某个事项单元的属性存在。

## Technical Summary
- `AtomizeResult` 新增 `recordUnits`，支持从新 schema 和旧 `atoms` schema 双向兼容解码。
- `record_units` schema 每条包含：`summary`、`attributes[]`、`tag_hints[]`、`confidence`、`start_char`、`end_char`。
- 当前 UI 兼容层会把 `summary` 作为主内容显示，并在必要时把未出现在 summary 里的 attributes 合并到同一条内容尾部。
- atomize payload policy 改为 `max_units: 4`，不再使用 `max_atoms`。

## Verification Steps
1. 重新拆分一条包含时间、程度、顺序信息的记录。
2. 观察是否更倾向 1-3 条较完整事项，而不是多个短句。
3. 确认 build 与 backend 语法通过。

## Rollback Notes
- 回滚 `AtomizationModels.swift`、`AIService.swift`、`server/server.js` 的 `record_units` 变更即可恢复旧 `atoms` schema。

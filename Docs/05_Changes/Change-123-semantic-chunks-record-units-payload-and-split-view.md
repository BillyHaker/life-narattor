---
date: 2026-03-15
owner: Codex
scope: AI/Data Model/UI
status: Done
---

# Change Log

## What Changed
将拆分链路从单步 `atoms` 过渡为结构化的 `semantic_chunks + record_units`。拆分页现在优先展示结构化 record units，而不是仅依赖被压扁后的 atom 文本。

## Files Changed
- `Life Narattor/Models/AtomizationModels.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Life Narattor/Data/AtomizationCoordinator.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`

## User-Visible Impact
- 拆分结果会更偏向“几件完整事项”，而不是句子碎片。
- 拆分页会直接显示每条事项的主摘要、上下文属性、行为过程。
- 重转写、重新整理、重新拆分后，不会继续显示上一次拆分留下的旧结构化结果。

## Technical Summary
- atomize schema 新增 `semantic_chunks`，并将 `record_units` 明确为 canonical 输出。
- `RecordUnitDraft` 新增 `context_attributes` 和 `behavioral_chain`，用于承接不能独立成事但不能丢失的信息。
- atomize prompt 改为“生活记录助手”角色：先提取语义块，再组装可单独回看/补充/搜索的事项单元。
- atomization 结果会保存到 `ArtifactEntity(artifactType = "atomization_payload")`。
- 拆分页优先读 `atomization_payload`，无 payload 时才回退旧 atom 列表。
- tag suggestion 输入改为读取 unit 的 summary + attributes + behavioral_chain + tag_hints，而不是只看压缩后的 atom 文本。

## Verification Steps
1. 对一条包含时间、程度、连续动作、感受的记录执行重新拆分。
2. 确认拆分页优先显示结构化事项，而不是只有压缩句子。
3. 重新整理或重新转写后，确认拆分页不会继续显示旧的拆分结构。
4. 运行 server 语法检查与 Xcode build。

## Rollback Notes
- 回滚 `AIService.swift` / `server/server.js` 的 atomize schema 与 prompt 可恢复旧 `record_units` 简化版。
- 回滚 `CaptureDetailSheet.swift` 中对 `atomization_payload` 的读取逻辑，可恢复旧 atom 列表展示。
- 回滚 `AtomizationCoordinator.swift` / `CaptureFeedViewModel.swift` 的 payload 存储与清理逻辑，可恢复“只存 atoms”的旧行为。

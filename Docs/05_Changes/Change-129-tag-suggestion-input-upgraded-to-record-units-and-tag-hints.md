---
date: 2026-03-16
owner: Codex
scope: Tag Suggestion Pipeline
status: Done
---

# Change Log

## What Changed
标签建议链不再只基于压扁的 atom 文本，而是升级为显式读取 `semantic_chunks`、`record_units` 和 `record_units.tag_hints`，使 AI 能更稳定地从记录单元的结构化含义中生成标签建议。

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/Data/AtomizationCoordinator.swift`
- `server/server.js`

## User-Visible Impact
- 标签建议会更倾向于复用与当前事项单元最接近的显性标签。
- 隐性标签建议会更贴近 `record_units` 的实际主题，而不是被压缩后的文本片段。
- 对复杂记录单元来说，标签建议质量会比之前更稳。

## Technical Summary
- `AIService` 的标签建议接口改为直接接收完整 `AtomizeResult`。
- OpenAI 直连和 backend `/v1/tags` 都改为使用结构化输入：
  - `semantic_chunks`
  - `record_units.summary`
  - `record_units.context_attributes`
  - `record_units.behavioral_chain`
  - `record_units.result_or_state`
  - `record_units.tag_hints`
- 标签建议 prompt 现在明确把 `tag_hints` 视为最强线索。
- `AtomizationCoordinator` 直接将 atomize 结果传入标签建议环节，减少中间压扁损耗。

## Verification Steps
1. 生成一条包含明显主题线索的拆分记录。
2. 确认标签建议阶段仍正常运行。
3. 确认建议优先复用标签库中的现有显性标签。
4. 执行 `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`。
5. 执行 Xcode build。

## Rollback Notes
- 如需回退，只需恢复 `suggestTags(...)` 的旧签名，并让标签建议重新读取扁平 `atoms` 文本。

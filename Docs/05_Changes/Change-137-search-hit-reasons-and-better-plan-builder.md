---
date: 2026-03-16
owner: Codex
scope: Retrieval Search Refinement
status: Done
---

# Change Log

## What Changed
增强了 `RetrievalPlanBuilder` 的 query understanding，并给 AI 检索结果增加了“为什么命中”的解释文案。

## Files Changed
- `Life Narattor/Models/SearchModels.swift`
- `Life Narattor/Data/RetrievalPlanBuilder.swift`
- `Life Narattor/Screens/SearchScreen.swift`

## User-Visible Impact
- 点击“用 AI 帮我找”后，结果卡片现在会显示轻量命中解释，如：
  - `命中标签：工作安排`
  - `命中隐性线索：加班`
  - `关联结果：感觉状态不错`
- 对常见查询（工作、情绪、英语、睡眠、饮食、执行）会更容易匹配到合适的标签过滤方向。

## Technical Summary
- `RetrievalPlanBuilder` 现在会：
  - 先看显性标签库命中
  - 再做常见主题的 inferred primary filters
  - 再根据 shape 生成 secondary filters
- `SearchResultItem` 新增 `hitReason`
- RetrievalPlan 搜索结果在映射回现有 UI 时会附带解释文案
- 保持 overview / focused 仍然共享同一套 retrieval path

## Verification Steps
1. 在搜索页输入与工作/情绪/英语等相关 query。
2. 点击“用 AI 帮我找”。
3. 确认结果卡片出现命中解释。
4. 运行构建命令确认通过。

## Rollback Notes
- 如需回退，可恢复 `SearchResultItem` 无 `hitReason` 字段，并撤销 `RetrievalPlanBuilder` 的 inferred filter 逻辑。
- 该改动不影响回顾页和标签主流程。

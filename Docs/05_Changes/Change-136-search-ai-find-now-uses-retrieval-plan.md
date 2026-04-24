---
date: 2026-03-16
owner: Codex
scope: Search RetrievalPlan Integration
status: Done
---

# Change Log

## What Changed
将搜索页中的“用 AI 帮我找”从占位提示改成真实的 `RetrievalPlan` 索引检索入口，并保持与现有搜索卡片、详情页跳转兼容。

## Files Changed
- `Life Narattor/Screens/SearchScreen.swift`

## User-Visible Impact
- 点击“用 AI 帮我找”后，不再弹占位提示。
- 搜索会改用统一的索引链：
  - 显性标签
  - 隐性标签
  - `record_units`
  - `tag_hints`
  来召回更相关的记录。
- 当前 UI 仍保持原有结果列表样式，不会出现第二套搜索界面。

## Technical Summary
- 搜索页新增 `isUsingRetrievalPlan` 状态。
- 新增 `performRetrievalSearch()`：
  - 通过 `RetrievalPlanBuilder` 构建 plan
  - 复用 `MemoryIndexStore.search(plan:)`
  - 把索引结果映射回 `SearchResultItem`
- 日期范围已同步进入 retrieval path。
- 标签过滤会影响 plan 中的显性标签过滤条件。
- 默认本地关键词搜索链仍保留，AI 检索作为用户显式触发的增强模式。

## Verification Steps
1. 在搜索页输入 query。
2. 点击“用 AI 帮我找”。
3. 确认结果列表正常出现，且仍能点开详情。
4. 运行构建命令确认通过。

## Rollback Notes
- 如需回退，可恢复 `SearchScreen` 原先的占位按钮与 `showingDeepSearchPlaceholder` 逻辑。
- 该改动不影响回顾页、标签库和拆分主流程。

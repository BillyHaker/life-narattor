---
date: 2026-03-16
owner: Codex
scope: Tag Memory Chain and Review Indexing
status: Done
---

# Change Log

## What Changed
将标签、隐性标签和 `tag_hints` 真正接入长期索引链，并把周回顾/月回顾改造成基于统一 `RetrievalPlan` 与 `MemoryIndexStore` 的回顾入口。

## Files Changed
- `Life Narattor/Models/RetrievalPlan.swift`
- `Life Narattor/Data/RetrievalPlanBuilder.swift`
- `Life Narattor/Data/MemoryIndexStore.swift`
- `Life Narattor/Data/ReviewRetrievalService.swift`
- `Life Narattor/Screens/WeeklyReviewScreen.swift`
- `Life Narattor/Screens/MonthlyReviewScreen.swift`

## User-Visible Impact
- 本周回顾 / 本月回顾不再只是简单拼接最近几条 `cleanText`。
- 回顾内容现在会使用：
  - 显性标签
  - 隐性标签
  - `record_units`
  - `tag_hints`
  来构建回顾骨架。
- 这为后续的季度叙事、主题回顾、项目回顾和更强的 AI 检索打下了统一索引基础。

## Technical Summary
- 新增 `NarrativeBrief` / `NarrativeBriefUnit` 中间层，作为回顾与叙事的 canonical 输入结构。
- `MemoryIndexStore` 增加：
  - `semanticChunks` 索引读取
  - `buildNarrativeBrief(plan:)`
  - 对显性标签、隐性标签、`tag_hints` 的汇总
- `ReviewRetrievalService` 封装：
  - 显性标签库读取
  - 开放回顾 plan 构建
  - 回顾 narrative 文本生成
  - timeline day 构建
- `WeeklyReviewScreen` / `MonthlyReviewScreen` 现已通过统一 retrieval path 生成 narrative。

## Verification Steps
1. 打开“本周回顾”与“本月回顾”，确认页面仍可进入且有内容时能正常显示 narrative。
2. 确认 narrative 来源不再只是最近几条原文，而会反映标签和事项单元。
3. 运行构建命令确认通过。

## Rollback Notes
- 如需回退，可恢复 `WeeklyReviewScreen` / `MonthlyReviewScreen` 原先直接 fetch captures 并拼接 `cleanText` 的实现。
- `NarrativeBrief`、`ReviewRetrievalService` 和 `MemoryIndexStore` 的改动可以独立回滚，不影响记录、拆分和标签主流程。

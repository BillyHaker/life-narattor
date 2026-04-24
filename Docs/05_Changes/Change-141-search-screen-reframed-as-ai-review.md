---
date: 2026-03-16
owner: Codex
scope: Search Screen Reframed as AI Review
status: Done
---

# Change Log

## What Changed
原先的搜索页从“普通搜索 + AI 检索”混合心智，收口为纯 `AI 回顾` 页面。普通关键词检索不再由此页承担。

## Files Changed
- `Life Narattor/Screens/SearchScreen.swift`

## User-Visible Impact
- 页面标题改为 `AI 回顾`。
- 输入框现在明确是问题型输入。
- 页面不再显示最近搜索等普通搜索遗留元素。
- 输出层固定为：AI 分析、证据整理、相关记录。

## Technical Summary
- 移除最近搜索区块。
- 停用普通搜索执行路径，统一走 AI 检索 / focused 证据链。
- 标签组和日期范围保留为 AI 回顾约束，不再表达为普通搜索过滤器。
- query 变化时改为重置 AI 回顾状态，而不是立即跑普通搜索。

## Verification Steps
1. 构建主工程。
2. 打开 AI 回顾页，确认页面标题和 placeholder 已变更。
3. 输入问题并点击 `开始 AI 回顾`，确认依次出现 AI 分析、证据整理、相关记录。

## Rollback Notes
- 如需回退，可恢复 `SearchScreen` 的普通搜索路径和最近搜索区块。
- focused 证据与 AI 分析能力可保留，不影响回退页面定位。

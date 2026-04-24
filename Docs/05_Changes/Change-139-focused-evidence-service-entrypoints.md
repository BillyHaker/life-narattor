---
date: 2026-03-16
owner: Codex
scope: Focused Evidence Service Entry Points
status: Done
---

# Change Log

## What Changed
把 focused 证据层正式收进 `ReviewRetrievalService`，提供统一入口和轻量摘要文本接口，避免后续功能再次绕过 service 层直接从 `NarrativeBrief` 手工组织证据。

## Files Changed
- `Life Narattor/Data/ReviewRetrievalService.swift`
- `Life Narattor/Screens/SearchScreen.swift`

## User-Visible Impact
- 搜索页在 focused 问题下会优先显示“证据整理”卡，先给结构化证据，再列相关记录。
- 用户可以展开具体证据分组，直接查看前段样本/后段样本/相关行为/相关状态的代表事项。
- 专题回顾、关系分析可以继续复用统一的 focused 证据输出和摘要文本。

## Technical Summary
- 新增 `makeFocusedEvidence(from:)`
- 新增 `makeFocusedEvidence(query:timeRangeOverride:)`
- 新增 `makeFocusedEvidenceText(from:)`
- `SearchScreen` 在 focused 查询时优先显示证据摘要卡，并把证据分组做成可展开结构。
- 统一 focused 证据构建链路：
  - `RetrievalPlanBuilder`
  - `MemoryIndexStore`
  - `NarrativeBrief`
  - `FocusedEvidenceBuilder`

## Verification Steps
1. 运行主工程构建。
2. 确认 `ReviewRetrievalService` 可以独立产出 `FocusedEvidenceBundle` 与摘要文本。

## Rollback Notes
- 如需回退，可移除 `ReviewRetrievalService` 中新增的 focused 证据接口，不影响 overview narrative 主链。

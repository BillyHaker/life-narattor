---
date: 2026-03-16
owner: Codex
scope: Focused Search AI Analysis and Anchor Refinement
status: Done
---

# Change Log

## What Changed
focused 检索链继续向可用分析入口推进：
- comparison / relation 查询加入了更具体的焦点锚点。
- 搜索页 focused 查询现在会先显示 AI 分析，再显示可展开的证据分组和命中记录。

## Files Changed
- `Life Narattor/Models/RetrievalPlan.swift`
- `Life Narattor/Data/RetrievalPlanBuilder.swift`
- `Life Narattor/Data/FocusedEvidenceBuilder.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Life Narattor/Screens/SearchScreen.swift`

## User-Visible Impact
- 输入 focused 问题时，搜索页会先展示一段更自然的 AI 证据分析。
- comparison / relation 问题的证据窗口文案更贴近用户原问题。
- 证据分组仍然可以展开查看具体事项。

## Technical Summary
- `RetrievalPlan` 增加 `focusAnchor` / `relationAnchors`。
- `RetrievalPlanBuilder` 新增 focused query 锚点抽取逻辑。
- `FocusedEvidenceBuilder` 使用这些锚点改善 comparison / relation 证据组织说明。
- `AIService` 新增 `analyzeFocusedEvidence(_:)`。
- backend proxy 新增 `/v1/focused-analysis`。
- `SearchScreen` focused 模式新增 AI 分析块与异步请求流程。

## Verification Steps
1. 校验 `server.js` 语法。
2. 构建 iOS 主工程。
3. 在搜索页输入 comparison / relation 类问题，确认会先出现 AI 分析，再显示证据分组。

## Rollback Notes
- 如需回退，可先移除 `SearchScreen` 的 AI 分析块，不影响 focused 证据组织主链。
- `/v1/focused-analysis` 与 `analyzeFocusedEvidence(_:)` 可独立回滚，不影响搜索检索结果列表。

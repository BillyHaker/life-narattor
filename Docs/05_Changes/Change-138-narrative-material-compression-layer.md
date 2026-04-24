---
date: 2026-03-16
owner: Codex
scope: Narrative Material Compression
status: Done
---

# Change Log

## What Changed
新增 `NarrativeMaterial` 压缩层，把统一检索链输出的 `NarrativeBrief` 进一步压缩成更适合长周期叙事和回顾生成的中间材料。

## Files Changed
- `Life Narattor/Models/RetrievalPlan.swift`
- `Life Narattor/Data/NarrativeMaterialBuilder.swift`
- `Life Narattor/Data/ReviewRetrievalService.swift`
- `Life Narattor/Screens/WeeklyReviewScreen.swift`
- `Life Narattor/Screens/MonthlyReviewScreen.swift`

## User-Visible Impact
- 本周回顾 / 本月回顾背后的 narrative 组织方式更稳定，不再直接依赖散的事项列表。
- 这为后续季度叙事、项目叙事、主题叙事奠定了统一的中间材料结构。

## Technical Summary
- 新增 `NarrativeMaterial`：
  - `primaryThemes`
  - `changeSignals`
  - `repeatedPatterns`
  - `turningPoints`
  - `representativeUnits`
  - `sections`
- 新增 `NarrativeMaterialBuilder`，负责从 `NarrativeBrief` 生成上述结构。
- `ReviewRetrievalService` 已改为：
  - 先生成 `NarrativeMaterial`
  - 再生成 narrative 文本和 timeline day
- 周/月回顾已接入这层压缩。

## Verification Steps
1. 打开本周回顾 / 本月回顾，确认页面仍可正常显示。
2. 确认 narrative 文本生成链不再直接依赖 `cleanText` 或简单 `overviewPoints`。
3. 运行构建命令确认通过。

## Rollback Notes
- 如需回退，可恢复 `ReviewRetrievalService` 直接使用 `NarrativeBrief` 的旧逻辑。
- `NarrativeMaterialBuilder` 与相关模型可独立回滚，不影响标签和搜索主链。

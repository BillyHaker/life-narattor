---
date: 2026-03-16
owner: Codex
scope: RetrievalPlan Design
status: Done
---

# Change Log

## What Changed
新增正式 ADR，定义长周期回顾与叙事生成的统一检索模型 `RetrievalPlan`，将 `overview` 与 `focused` 收敛为同一套检索系统的两种查询形态。

## Files Changed
- `Docs/03_Decisions/ADR-011-retrieval-plan-for-review-and-narrative.md`

## User-Visible Impact
- 当前无直接 UI 变化。
- 该决策会影响后续：周/月回顾、主题回顾、项目回顾、季度整合和第二自我相关的检索与叙事质量。

## Technical Summary
- 定义了 `RetrievalPlan` 的核心字段：
  - `mode`
  - `time_range`
  - `primary_filters`
  - `secondary_filters`
  - `tag_scope_weights`
  - `ranking_weights`
  - `compression_policy`
  - `question_shape`
- 明确 `overview` / `focused` 不是两套系统，而是同一条检索流水线的不同参数配置。
- 明确隐性标签和 `tag_hints` 应宽进入索引层，但最终召回与叙事质量由提取阶段的过滤、排序、压缩控制。

## Verification Steps
1. 阅读 ADR，确认 overview / focused 不再被定义为两套系统。
2. 确认标签宽录入、后提取的边界与现有标签设计一致。
3. 后续实现时以此 ADR 为准。

## Rollback Notes
- 如需回退，可删除该 ADR 并恢复为未定方案；当前无代码影响。

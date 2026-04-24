---
date: 2026-03-16
owner: Codex
scope: Tag Recommendation Ranking
status: Done
---

# Change Log

## What Changed
为标签建议增加了轻量元数据与本地排序规则，使“哪些显性标签值得推荐”不再完全依赖 AI 原始输出顺序。

## Files Changed
- `Life Narattor/Models/TagRecommendationMetadata.swift`
- `Life Narattor/Data/AtomTagStore.swift`

## User-Visible Impact
- 现有显性标签建议会更稳定，优先推荐：
  - 匹配度高
  - 更具体
  - 更稳定
  - 用户历史上更常确认的标签
- 新标签候选会更保守，过泛、过弱的候选更不容易进入建议列表。

## Technical Summary
- 新增代码侧元数据：
  - `recommendability`
  - `scope`
  - `stability`
- 不修改 Core Data schema，先通过代码规则实现推荐排序。
- 已有显性标签建议排序综合使用：
  - AI score
  - 元数据权重
  - 历史确认次数
- 新标签候选排序与过滤综合使用：
  - AI score
  - 元数据权重
  - 泛词过滤

## Verification Steps
1. 触发一条新的拆分与标签建议。
2. 确认已有显性标签建议优先出现具体、稳定的标签。
3. 确认过泛的新候选标签不容易出现在建议中。
4. 执行 Xcode build。

## Rollback Notes
- 如需回退，可移除 `TagRecommendationMetadata.swift` 并恢复 `AtomTagStore` 中的原始建议顺序逻辑。

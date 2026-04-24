---
date: 2026-03-16
owner: Codex
scope: Tag Ownership Boundary
status: Done
---

# Change Log

## What Changed
收紧了标签写入边界：显性标签现在只会来自用户主动创建，或用户接受推荐标签。AI 推荐阶段不再直接创建新显性标签。

## Files Changed
- `Life Narattor/Data/AtomTagStore.swift`

## User-Visible Impact
- 推荐标签仍然会出现，但 AI 不会再悄悄把新标签直接加入显性标签库。
- 对于不存在于显性标签库中的新候选标签，用户确认后它才会转成正式显性标签。
- 已有显性标签的推荐仍可直接作为“建议标签”出现在记录上。

## Technical Summary
- `assignVisibleTagSuggestions(...)` 现在只允许复用已存在的显性标签，不再调用 `addTag(...)`。
- `assignHiddenTagSuggestions(...)` 和通用建议路径中的隐藏建议会以 `isSuggested = true` 形式挂到 atom，便于用户确认。
- `fetchTagMap(...)` 改为允许“被建议的隐藏标签”显示在详情页，但普通隐藏标签仍然不对用户可见。
- `confirmSuggestedTag(...)` 会在用户确认时把隐藏标签升级为 `isUserVisible = true`。

## Verification Steps
1. 生成一条带标签建议的记录。
2. 确认推荐阶段不会直接把新标签写入显性标签库。
3. 在详情页接受一个新标签候选。
4. 确认该标签在接受后才进入显性标签库。
5. 执行 Xcode build。

## Rollback Notes
- 如需回退到旧行为，可恢复 `assignVisibleTagSuggestions(...)` 中的 `addTag(...)` 调用，并撤回 `confirmSuggestedTag(...)` 对隐藏标签显性化的处理。

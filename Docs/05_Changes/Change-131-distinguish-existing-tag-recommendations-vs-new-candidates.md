---
date: 2026-03-16
owner: Codex
scope: Tag Suggestion UI
status: Done
---

# Change Log

## What Changed
详情页中的建议标签现在会明确区分两类：
- 复用已有显性标签的推荐
- 尚未进入显性标签库的新标签候选

## Files Changed
- `Life Narattor/Models/AtomItem.swift`
- `Life Narattor/Data/AtomTagStore.swift`
- `Life Narattor/Screens/SearchScreen.swift`
- `Life Narattor/Screens/ProjectDetailScreen.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`

## User-Visible Impact
- 建议标签不再统一显示成“建议”。
- 现在会分别显示：
  - `标签名 · 推荐`
  - `标签名 · 新建议`
- 新标签候选会使用不同背景色，帮助用户理解自己点击接受后会把它加入显性标签库。

## Technical Summary
- `TagItem` 新增 `isUserVisible`。
- 详情页标签胶囊文案与颜色基于：
  - `isSuggested`
  - `isUserVisible`
 共同决定。
- 推荐标签确认逻辑不变，但用户现在能看懂推荐来源。

## Verification Steps
1. 打开一条带建议标签的记录。
2. 确认已有显性标签显示为 `推荐`。
3. 确认新标签候选显示为 `新建议`。
4. 点击接受，确认标签状态更新正常。
5. 执行 Xcode build。

## Rollback Notes
- 如需回退，可移除 `TagItem.isUserVisible` 和详情页中的差异化展示，恢复统一“建议”文案。

---
date: 2026-03-16
owner: Codex
scope: Tag Review Entry Points
status: Done
---

# Change Log

## What Changed
回顾首页现在不再只支持“按项目回顾”和“按主题回顾”，而是完整支持 6 组显性标签回顾，并提供统一的标签库入口。

## Files Changed
- `Life Narattor/Screens/ReviewHomeScreen.swift`

## User-Visible Impact
- 回顾页新增“按标签回顾”板块。
- 用户现在可以直接从回顾页进入：
  - 按项目回顾
  - 按习惯回顾
  - 按主题回顾
  - 按人物回顾
  - 按目标回顾
  - 按场景回顾
- 回顾页新增“标签库”入口，不再需要去项目页才能管理标签。
- 每个标签组会显示当前可回顾标签数量。

## Technical Summary
- `ReviewHomeScreen` 新增 `visibleTagCounts`，实时统计 6 组显性标签数量。
- 回顾首页入口由按钮改为 6 组卡片式导航，直接对接 `ReviewByTagPickerScreen(tagType:)`。
- 工具栏增加标签管理快捷入口。
- 为避免命名冲突，将首页本地片段模型改名为 `ReviewHomeSnippet`。

## Verification Steps
1. 打开回顾页。
2. 确认“按标签回顾”区域包含 6 组入口。
3. 点击任一组，确认能进入对应 `ReviewByTagPickerScreen`。
4. 点击“标签库”入口，确认能打开 `TagManagerScreen`。
5. 执行 Xcode build。

## Rollback Notes
- 如需回退，可恢复 `ReviewHomeScreen.swift` 为仅包含项目/主题回顾按钮，并移除标签库快捷入口。

---
date: 2026-03-15
owner: Codex
scope: UI
status: Done
---

# Change Log

## What Changed
拆分页不再显示 atom 的类型图标和类型文案，也不再从该页菜单暴露“更改类型”。

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`

## User-Visible Impact
- 拆分页更接近“内容单元列表”，不再让兼容层类型标签干扰对拆分质量的判断。

## Technical Summary
- `CaptureAtomRowView` 去掉行头类型 icon/title。
- 行内菜单去掉“更改类型”，保留标签、重点、删除、来源等与当前页相关的操作。

## Verification Steps
1. 打开任一记录详情页的“拆分”。
2. 确认每条只显示内容，不显示 `行动/感受/决定` 等类型。
3. 确认行内菜单不再出现“更改类型”。

## Rollback Notes
- 回滚 `CaptureDetailSheet.swift` 中 `CaptureAtomRowView` 的头部与菜单即可恢复旧显示。

# Change-021 — Tag Manager screen

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Tags
- Related Skills:
  - Skills/tags/SKILL.md
  - Skills/ia-navigation/SKILL.md
- Related ADRs: None
- Status: Done

## What changed
- Added Tag Manager screen with segmented tag types, create/rename/merge/delete flows.
- Wired Projects top-right gear to Tag Manager.

## Files touched
- Life Narattor/Life Narattor/Screens/TagManagerScreen.swift
- Life Narattor/Life Narattor/Screens/ProjectsListScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Users can manage tags (create/rename/merge/delete) from the Projects tab.

## Verification steps
1) Open Projects tab → tap gear icon → Tag Manager opens.
2) Switch segmented control between 项目/主题/人物/目标.
3) Tap “新建标签” → enter name → tag appears in list.
4) Tap tag menu → 重命名 → name updates.
5) Tap tag menu → 合并到… → select target → 确认合并.
6) Tap tag menu → 删除 → tag disappears from list.

## Rollback plan
- Revert `Life Narattor/Life Narattor/Screens/TagManagerScreen.swift` and `Life Narattor/Life Narattor/Screens/ProjectsListScreen.swift`.

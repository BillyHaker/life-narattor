---
date: 2026-03-15
owner: Codex
scope: UI
status: Done
---

# Change Log

## What Changed
移除了记录详情页 `原始` tab 正文区域中重复的 `重新转写` 按钮，只保留顶部工具栏中的统一 `重新转写` 入口。

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`

## User-Visible Impact
- 原始页不会再同时出现两个 `重新转写` 入口。
- 顶部按钮继续负责重新转写；正文区域保留 `复制转写` 和状态提示。

## Technical Summary
- 移除转写状态行中的内联 `重新转写` 按钮。
- 移除转写正文下方的重复 `重新转写` 按钮。
- 顶部工具栏逻辑不变，继续作为唯一重试入口。

## Verification Steps
1. 打开一条语音记录详情页。
2. 切到 `原始` tab。
3. 确认只在顶部看到 `重新转写`，正文区域不再重复出现。
4. 确认 Xcode build 通过。

## Rollback Notes
- 如需恢复旧交互，只需在 `CaptureDetailSheet.swift` 中重新加入两个正文区域按钮。

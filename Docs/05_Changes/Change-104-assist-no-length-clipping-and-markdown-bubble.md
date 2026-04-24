# Change-104 — Assist No Length Clipping and Markdown Bubble

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / UI / Reply handling
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 移除了聊天回复路径中的字符长度裁剪
- 助手消息气泡支持 Markdown 渲染

## Why
- 长度裁剪会把编号列表截断，导致出现孤立的 `4.`
- 助手消息原先直接用 `Text(message.text)`，不会解析 `**粗体**`

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-03-14_session-008.md`
- `Docs/05_Changes/Change-104-assist-no-length-clipping-and-markdown-bubble.md`

## User-visible impact
- 助手回复不再因为本地裁剪而被截断
- `**text**` 之类的 Markdown 样式会正常显示

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback Notes
- Revert the Markdown rendering and reply clipping changes if needed.

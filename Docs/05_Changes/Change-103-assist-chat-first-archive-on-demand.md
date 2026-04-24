# Change-103 — Assist Chat-First, Archive On Demand

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / Architecture / UI
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 新增纯聊天接口 `chatReply`
- 保留 `assistArchive` 专门用于生成记录草稿
- 聊天发送时不再预生成 `AssistArchivePayload`
- 点“整理为记录”时才生成归档卡片

## Why
- 之前聊天入口直接走 `assistArchive`
- schema 强制同时生成 `reply + archive_card + turn_policy`
- 这天然把模型往摘要和归档导向推，而不是自然聊天
- 拆开后，聊天和归档不再互相污染

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-14_session-007.md`
- `Docs/05_Changes/Change-103-assist-chat-first-archive-on-demand.md`

## User-visible impact
- 助手回复现在先走纯聊天链路
- “整理为记录”会在点击时再生成草稿
- 这会更接近聊天模型，而不是每轮都像在顺便写归档摘要

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Check proxy syntax:
   - `node --check server/server.js`
3. Manual QA:
   - 发一条助手消息，确认先看到纯聊天回复
   - 点击“整理为记录”，确认此时才生成待确认归档卡

## Rollback Notes
- Revert the new `chatReply` path and restore the previous `assistArchive`-first flow.

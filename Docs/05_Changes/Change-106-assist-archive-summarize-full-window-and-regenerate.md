# Change-106 — Assist Archive Summarize Full Window and Regenerate

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / Archive generation / UI
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- “整理为记录”现在会总结整个当前窗口，而不是只偏向最后一条用户消息
- 归档生成时使用当前窗口全量消息作为上下文
- 待确认卡的次按钮从“重开会话”改成“重新整理”

## Why
- 之前归档生成只取最后一条用户消息作为 `questionText`
- 即使 `contextText` 带了上下文，也会导致模型更偏向最后一轮
- UI 的“重开会话”也不再符合新的按需归档流程

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-03-14_session-010.md`
- `Docs/05_Changes/Change-106-assist-archive-summarize-full-window-and-regenerate.md`

## User-visible impact
- “整理为记录”更可能覆盖整个窗口中的多个相关交流点
- 用户可以在当前会话上直接重新整理，而不是被引导去重开会话

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Manual QA:
   - 在同一窗口连续聊多个相关单词
   - 点击“整理为记录”
   - 预期：草稿覆盖整个窗口内容，而不是只剩最后一轮

## Rollback Notes
- Revert the full-window archive prompt construction and regenerate button changes if needed.

# Change-099 — Assist Thread-Scoped Context and Reply Binding

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / Conversation state
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 助手请求上下文现在按当前 `threadID` 现读消息后构造
- 本地回复整形与追问承接逻辑现在显式接收当前线程消息
- AI 回包保存到发起请求的 thread，并且只有当前仍在该 thread 时才更新当前界面

## Why
- 之前上下文构造和回复整形依赖全局 `assistSessionMessages`
- 如果用户在请求过程中切到别的窗口，当前内存态可能已经不是原始 thread
- 这会导致：
  - 发给 AI 的上下文不够严格地只属于当前窗口
  - A 窗口的回包可能污染 B 窗口当前界面

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-14_session-003.md`
- `Docs/05_Changes/Change-099-assist-thread-scoped-context-and-reply-binding.md`

## User-visible impact
- 同一个窗口的上下文继承更稳定
- 新窗口不会带入别的窗口上下文
- 请求进行中切换窗口时，回包不会串到当前窗口

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Manual QA:
   - 在窗口 A 发两轮对话
   - 新建窗口 B 发一轮无关问题
   - 切回 A 再继续追问
   - 预期：A 只接 A 的上下文，B 只接 B 的上下文

## Rollback Notes
- Revert the thread-scoped context helpers and reply writeback guards in `CaptureFeedViewModel.swift`.

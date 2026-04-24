# Change-101 — Assist Prompt: Answer First, Concise, Precise

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / Prompting
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 调整 assistant runtime prompt
- 新的重点只有：
  - 直接回答问题
  - 从答案开始
  - 简洁精确
  - 默认 2-4 句
  - 仅在必要时问一个直接澄清问题

## Why
- 之前的方向开始重新叠加约束，偏离了“接近原生聊天效果”的目标
- 这轮明确回到更克制的提示词策略，只收紧回答风格，不继续增加结构控制

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-14_session-005.md`
- `Docs/05_Changes/Change-101-assist-prompt-answer-first-concise-precise.md`

## User-visible impact
- 助手更倾向于直接给答案，而不是先铺垫
- 回复长度更集中在 2-4 句

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback Notes
- Revert the assistant prompt changes in `AIService.swift` and `server/server.js`.

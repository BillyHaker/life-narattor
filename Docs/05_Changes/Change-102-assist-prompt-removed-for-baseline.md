# Change-102 — Assist Prompt Removed for Baseline

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / Prompting
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 移除了 assistant runtime prompt 中所有行为、风格、长度、角色提示
- 仅保留 `Return JSON only.` 以维持 schema 解码

## Why
- 当前需要先看模型在几乎无提示词状态下的基线表现
- 这能帮助区分问题到底来自提示词，还是来自更底层的链路与模型能力

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-14_session-006.md`
- `Docs/05_Changes/Change-102-assist-prompt-removed-for-baseline.md`

## User-visible impact
- 助手将不再受到当前行为提示词约束
- 当前轮次可以直接观察近似“裸模型”回复

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback Notes
- Restore the previous assistant prompt text in `AIService.swift` and `server/server.js`.

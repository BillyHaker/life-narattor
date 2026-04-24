# Change-100 — Assist Minimal Prompt and No Analytical Rewrite

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / Prompting / Reply generation
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 将 assistant runtime prompt 改成极简版本
- 去掉本地聊天回复的大部分分析合同重写
- fallback 路径不再强制生成“判断 + 动作 + 追问”式回复

## Why
- 当前助手效果差，不是因为模型太弱，而是因为：
  - 系统提示词过重
  - 本地后处理过强
  - fallback 会把正常回复再次改写成模板化分析
- 如果目标是接近原生 ChatGPT，应该减少控制层，而不是继续增加规则

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-14_session-004.md`
- `Docs/05_Changes/Change-100-assist-minimal-prompt-and-no-analytical-rewrite.md`

## User-visible impact
- 助手回复会更接近自然聊天，而不是固定分析模板
- 简单问题默认更短
- fallback 回复不再强行变成教练式结构

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Manual QA:
   - 发一个简单问题
   - 发一个需要多轮澄清的问题
   - 观察回复是否不再固定落成“先判断、再动作、再追问”的模板

## Rollback Notes
- Revert the minimal prompt changes and restore the previous analytical rewrite path if needed.

# Change-086 — Assist AI Reply Fallback to QuickAck

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistFlow/AI
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Strengthened assist reply path to ensure users get AI text replies after sending input:
  - primary: `aiService.assistArchive(...)`
  - fallback: if primary fails, call `aiService.quickAck(...)` and synthesize `AssistArchivePayload` from AI result.
- Failure messaging updated:
  - only when both paths fail, show `AI 回复失败，请重试。` and assistant bubble explains failure.

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-08_session-039.md`
- `Docs/05_Changes/Change-086-assist-ai-reply-fallback-to-quickack.md`

## Contracts/DB changes
- None.

## User-visible impact
- In assistant chat, sending text now has much higher chance to get an AI reply (instead of hard failure on structured path).

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`

## Rollback Notes
- Revert files listed in `Files Changed`.

# Change-098 — Assist Follow-up Context Binding

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / Conversation quality
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 更新 `CaptureFeedViewModel` 的助手回复整形逻辑
- 对短回复增加“承接上一轮追问”的上下文绑定
- 对发音类问题增加 `onset / vowel / ending` 焦点判断，避免重复追问

## Why
- 之前的本地整形与 fallback 只看当前一句 `questionText`
- 当用户只回复“开头”这类短答案时，系统会把它当成全新问题
- 结果是掉回通用 analyze 模板，而不是继续回答刚才那条发音问题

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-14_session-002.md`
- `Docs/05_Changes/Change-098-assist-follow-up-context-binding.md`

## User-visible impact
- 助手在多轮对话里会更像连续交流，而不是每轮重开
- 对发音类澄清回答时，会直接进入下一步说明而不是重复发问

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Manual QA:
   - 先问：`我讲话分不清 fan,fine`
   - 助手追问后答：`开头`
   - 预期：助手直接给开头起音的解释和动作，不再重复问“想先验证哪个变量”

## Rollback Notes
- Revert `Life Narattor/ViewModels/CaptureFeedViewModel.swift` to remove the follow-up context binding helpers and pronunciation focus contract.

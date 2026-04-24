# Change-093 — Assist Remove Filler and Single-word Pronunciation Support

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistPrompt/AssistFallback
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 解决“仍然模板化”：
  - 删除本地 fallback 中高频套话与无效空话。
  - 非必要不再输出泛化鼓励段落。
- 发音识别升级：
  - 从“至少两个英文词”改为支持“单词级”发音问题。
  - 新增线索词：`咬嘴/绕口/嘴瓢/说不清/讲不清楚`。
  - `crazy` 增加音标映射：`/ˈkreɪzi/`。
- Prompt 收紧：
  - app/proxy 均增加“禁止元话术开场”规则（例如“我理解你这轮…”）。

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-08_session-046.md`
- `Docs/05_Changes/Change-093-assist-remove-filler-and-single-word-pronunciation.md`

## User-visible impact
- 输入短句如“我英文讲不清楚 crazy 感觉很咬嘴”时，首答会直接给具体原因+短动作，不再空话铺垫。
- 单词场景也会给音标和针对练法，不再误走“通用建议”模板。

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `BUILD SUCCEEDED`
2. Proxy syntax:
   - `node --check /Users/billyha/Desktop/Life Narattor/server/server.js`
   - Result: pass

## Rollback Notes
- 如需回退，恢复以下文件到上一个稳定版本：
  - `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
  - `Life Narattor/AI/AIService.swift`
  - `server/server.js`

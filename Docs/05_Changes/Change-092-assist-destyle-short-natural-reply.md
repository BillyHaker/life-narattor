# Change-092 — Assist De-template and Natural Short Reply

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistPrompt/AssistFallback
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- 调整 app 与 proxy 的 assist 系统提示词:
  - 默认首答改为 3-5 句自然中文。
  - 非用户明确要求时，不输出固定 `Why/How/下一步` 编号结构。
  - 每轮优先给一个最小可执行动作（30-60 秒）+ 一个关键追问。
  - 保留文本输入约束，不要求图片/文件/外部语音。
- 重写本地回复 enrich 逻辑，避免回退路径模板化:
  - 增加模板检测与纯复述检测。
  - 默认走短自然回复，增强会话衔接。
  - 仅用户明确要求时才生成详细模式。
- 发音场景保留实用细节:
  - 继续输出 `fan /fæn/`、`fine /faɪn/`。
  - 将练习建议收敛为短时、可立即执行的动作。

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `server/server.js`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-045.md`
- `Docs/05_Changes/Change-092-assist-destyle-short-natural-reply.md`

## Contracts/DB changes
- None.

## User-visible impact
- 助手默认回复更像自然对话，不再固定模板分段。
- 短输入也会主动分析原因并给可执行动作，不需要用户补齐完整提问格式。
- 回复更连贯，会引用上文而不是每轮重置成通用话术。

## Verification Steps
1. Build verification:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `BUILD SUCCEEDED`
2. Proxy syntax verification:
   - `node --check /Users/billyha/Desktop/Life Narattor/server/server.js`
   - Result: pass

## Rollback Notes
- 直接回滚本次改动文件即可:
  - `Life Narattor/AI/AIService.swift`
  - `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
  - `server/server.js`
- 如需仅回退回复风格，不影响线程与记录逻辑，优先回滚 `CaptureFeedViewModel.swift` 的 enrich/helper 变更。

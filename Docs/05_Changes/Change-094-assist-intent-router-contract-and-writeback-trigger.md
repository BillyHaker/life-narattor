# Change-094 — Assist Intent Router, Contract Reply, and Write-back Trigger

## Meta
- Date: 2026-03-09
- Owner: Codex (GPT-5)
- Scope: iOS/AssistPipeline/Prompting
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 在助手回复链路加入“意图路由”：
  - 识别 `record/analyze/execute/decision/reflect/unknown` 六类意图。
- 引入“单核心输出合同”：
  - 输出统一收敛到 `确认 + 1个核心原因 + 1个最小动作 + 1个成功标准 + 1个追问`。
  - 默认长度限制，抑制教练式冗长回答。
- 新增“反模板判定 + 归一化”：
  - 检测模板化与纯复述。
  - 缺少动作/标准时自动重写为合同格式。
  - 去除高频元话术与空话。
- 写入意图快捷处理：
  - 用户说“记进去/记录一下/整理成记录”等时，AI 回复后自动打开待确认记录卡（不自动提交）。
- 模型侧约束同步：
  - app 侧 `AIService` 与 proxy 侧 prompt 均增加“意图分型 + 单核心合同 + 长度控制”规则。

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-09_session-047.md`
- `Docs/05_Changes/Change-094-assist-intent-router-contract-and-writeback-trigger.md`
- `Docs/VERIFICATION_BACKLOG.md`

## Contracts/DB changes
- None.

## User-visible impact
- 助手回复更稳定、短、聚焦，不再每轮展开“讲义式”内容。
- “记进去”类指令更顺手：会自动展开待确认卡，减少额外点击。
- 发音单词输入场景与多词输入场景输出逻辑统一且更稳。

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `BUILD SUCCEEDED`
2. Proxy syntax:
   - `node --check /Users/billyha/Desktop/Life Narattor/server/server.js`
   - Result: pass

## Rollback Notes
- 回滚以下文件可完整撤销本次行为变更：
  - `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
  - `Life Narattor/AI/AIService.swift`
  - `server/server.js`

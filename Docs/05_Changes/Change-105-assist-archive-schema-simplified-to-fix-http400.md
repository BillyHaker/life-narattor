# Change-105 — Assist Archive Schema Simplified to Fix HTTP 400

## Meta
- Date: 2026-03-14
- Owner: Codex (GPT-5)
- Scope: Assistant / API / Archive generation
- Related Skills: dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 简化了 `assist_archive` 的 JSON schema
- 不再要求模型直接生成完整的嵌套 `archive_card` 和 `turn_policy`
- 改为只生成：
  - `reply`
  - `title`
  - `context`
  - `key_points`
  - `next_steps`
- 其余字段在本地或 proxy 中补默认值

## Why
- 聊天链路 `chat_reply` 正常
- “整理为记录”链路单独返回 HTTP 400
- 这说明问题更可能在 `assist_archive` 的请求 schema，而不是基础连接、密钥或模型不可用
- 收缩 schema 是当前最稳的修法

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-14_session-009.md`
- `Docs/05_Changes/Change-105-assist-archive-schema-simplified-to-fix-http400.md`

## User-visible impact
- “整理为记录”更不容易因为 schema 被 AI 服务拒绝
- 草稿卡的默认补全字段将由本地代码填充

## Verification Steps
1. Build app target:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Check proxy syntax:
   - `node --check server/server.js`
3. Manual QA:
   - 聊天正常后点击“整理为记录”
   - 预期：不再出现 HTTP 400

## Rollback Notes
- Restore the previous nested `assist_archive` schema if needed.

---
date: 2026-03-14
owner: Codex
scope: AI/API
related_skills:
  - atomization
status: Done
---

# Change Log

## What Changed
将 OpenAI 直连 atomize 的 JSON schema 调整为与 backend `/v1/atomize` 一致，降低 OpenAI Responses strict schema 下触发 HTTP400 的概率。

## Files Changed
- `Life Narattor/AI/AIService.swift`

## User-Visible Impact
- 若 app 当前走 OpenAI 直连 atomize，重新拆分时更不容易出现 `AI 服务异常 HTTP400`。

## Technical Summary
- `confidence` 改为 `number | null`
- `start_char` / `end_char` 改为 `integer | null`
- 原子项 required 改为 `type/content/confidence/start_char/end_char`
- 顶层补齐 `atomize_version` required，类型为 `string | null`
- 使 OpenAI 直连与 backend atomize 契约同构，减少 strict schema 拒绝概率

## Verification Steps
1. 运行 `xcodebuild ... build`
2. 在 app 内对一条未拆分记录点击 `重新拆分`
3. 预期：不再直接报 `AI 服务异常 HTTP400`

## Rollback Notes
- 仅回滚 `AIService.swift` 中 `atomizeSchema()` 即可恢复旧 schema。

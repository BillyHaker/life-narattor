# Change-046 — DevTools keychain key override

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools/AI
- Related Skills: devtools-debug-suite
- Related ADRs:
- Status: Done

## What changed
- Added a Keychain-backed override for OPENAI_API_KEY in DevTools AI Connection Test.
- OpenAIConfig now reads env first, then Keychain fallback.

## Files touched
- `Life Narattor/Life Narattor/DevTools/KeychainStore.swift`
- `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`
- `Life Narattor/Life Narattor/AI/AIService.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Developers can paste a key in DevTools to enable OpenAI without relying on Scheme env variables.

## Verification steps
1) Open DevTools → AI Connection Test.
2) Paste a key and tap “保存到 Keychain”.
3) Confirm status shows “已设置（Keychain 末四位 …）”.
4) Run “测试 OpenAI 连接” and confirm success.

## Rollback plan
- Revert edits in files listed above and remove KeychainStore.swift.

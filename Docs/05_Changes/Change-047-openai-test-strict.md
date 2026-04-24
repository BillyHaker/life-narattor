# Change-047 — OpenAI test strict

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools
- Related Skills: devtools-debug-suite
- Related ADRs:
- Status: Done

## What changed
- AI Connection Test now uses OpenAIService directly and fails fast when no key is configured (avoids Mock fallback success).

## Files touched
- `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Connection test now clearly indicates when OpenAI key is missing and only reports success on real OpenAI calls.

## Verification steps
1) Open AI Connection Test with no key configured → should show "未配置 OpenAI Key".
2) Save key to Keychain and rerun test → should show "连接成功（OpenAI）".

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift`.

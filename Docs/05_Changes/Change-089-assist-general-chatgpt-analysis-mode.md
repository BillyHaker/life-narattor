# Change-089 — Assist General ChatGPT Analysis Mode

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistPrompt/Behavior
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Repositioned assist behavior from narrow pronunciation-only coaching to general ChatGPT-like analysis mode:
  - intent understanding + deeper analysis + actionable suggestions + optional supplementary material.
  - keep pronunciation drills only when topic is pronunciation/language.
- Updated both app-side and proxy-side assist prompts accordingly.
- Updated in-app fallback/enrichment synthesis to be domain-adaptive:
  - pronunciation topics -> include mouth-position/contrast drills.
  - generic topics -> include analysis framework + execution plan.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `server/server.js`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-042.md`
- `Docs/05_Changes/Change-089-assist-general-chatgpt-analysis-mode.md`

## Contracts/DB changes
- None.

## User-visible impact
- Assistant replies should feel like normal AI problem-solving chat, with deeper explanation and practical next steps.
- Recording remains explicit/manual and secondary.

## Verification Steps
1. App build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`
2. Proxy runtime:
   - `node --check server.js`
   - `./manage_launchd_proxy.sh restart`
   - `curl http://127.0.0.1:8787/healthz`
   - Result: `{"status":"ok"}`

## Rollback Notes
- Revert files listed in `Files Changed`.

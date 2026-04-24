# Change-090 — Implicit Intent Why/How Default

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistIntent/Prompting
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Added implicit-intent handling so user can state a problem without explicit asks.
- Assistant now proactively answers `why + how` when it detects problem statements.
- Pronunciation-topic detection now supports confusion-style wording (e.g. `说混`, `分不清`, `总把...混`).
- Updated app/proxy prompts to require proactive inference for statement-only inputs.
- Reinstalled launchd proxy agent to ensure current startup command and stable runtime.

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Docs/04_Sessions/2026-03-08_session-043.md`
- `Docs/05_Changes/Change-090-implicit-intent-why-how-default.md`

## Verification Steps
1. Build: `xcodebuild ...` => `EXIT:0`
2. Proxy:
   - `./manage_launchd_proxy.sh install`
   - `curl http://127.0.0.1:8787/healthz` => `{"status":"ok"}`

## Rollback Notes
- Revert files listed above.

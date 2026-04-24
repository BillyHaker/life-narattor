# Change-091 — Assist Secretary Style and Unsupported Input Guard

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistPrompt/Tone/UXConstraints
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Refined assistant persona to "personal assistant/secretary" (user-goal-first, practical, conversational).
- Made why/how reasoning default for any input, including statement-only problem reports.
- Added explicit unsupported-input guard in app/proxy prompts:
  - do not request image/file/external audio uploads.
  - follow-up questions must remain text-based.
- Upgraded local fallback synthesis:
  - pronunciation confusion now includes IPA where available (`fan /fæn/`, `fine /faɪn/`).
  - tone shifted from teacher-like to assistant-like practical coaching.
  - removed direct requirement for unsupported input forms.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `server/server.js`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-044.md`
- `Docs/05_Changes/Change-091-assist-secretary-style-and-unsupported-input-guard.md`

## Contracts/DB changes
- None.

## User-visible impact
- Assistant sounds more like a practical secretary/helper rather than a lecture-style coach.
- Even short statements trigger proactive why/how guidance.
- Replies no longer push unsupported media input paths.

## Verification Steps
1. App build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`
2. Proxy runtime:
   - `node --check server.js`
   - `./manage_launchd_proxy.sh install`
   - `curl http://127.0.0.1:8787/healthz`
   - Result: `{"status":"ok"}`

## Rollback Notes
- Revert files listed in `Files Changed`.

# Change-088 — Assist First-Turn Coaching Response

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistPrompt/ResponseQuality
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Strengthened assist prompting for first-turn quality in both app and backend proxy:
  - require difficulty diagnosis + error source + mouth-position drills + short practice plan.
  - include conversation context in backend assist request (`context_text`).
- Added response-quality guard in app:
  - if structured assist reply is too generic/short, enrich it into coaching-style output.
  - fallback (`quickAck`) path now also builds structured coaching reply and practice steps.
- Goal: reduce generic paraphrase replies and provide immediately actionable training content.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `server/server.js`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-041.md`
- `Docs/05_Changes/Change-088-assist-first-turn-coaching-response.md`

## Contracts/DB changes
- None.

## User-visible impact
- First assistant response is more likely to include concrete phonetic diagnosis and oral drills.

## Verification Steps
1. App build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`
2. Server syntax + runtime:
   - `node --check server.js`
   - `./manage_launchd_proxy.sh restart`
   - `./manage_launchd_proxy.sh status` and `/healthz`
   - Result: service running + `{"status":"ok"}`

## Rollback Notes
- Revert files listed in `Files Changed`.

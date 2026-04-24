# Change-087 — Assist Normal Chat and Manual Record Draft

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistUX/AIProxy
- Related Skills: capture-ui, dev-logging-system, verification-consolidation
- Related ADRs: None
- Status: Done

## What changed
- Improved assist response quality prompt to avoid pure restatement:
  - OpenAI direct assist prompt now asks for diagnosis + concrete guidance + next step.
  - backend `/v1/assist` prompt updated similarly.
  - backend now consumes `payload.context_text` for richer conversation context.
- Updated backend assist request payload to include context text.
- Changed assistant interaction rhythm:
  - draft confirmation card no longer auto-opens on each turn.
  - user must click `整理为记录` to open pending record card.
  - supports `继续对话` to collapse draft and keep chatting.
- Kept reliability fallback:
  - if structured assist fails, fallback to `quickAck` path for AI text reply.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `server/server.js`
- `Docs/VERIFICATION_BACKLOG.md`
- `Docs/04_Sessions/2026-03-08_session-040.md`
- `Docs/05_Changes/Change-087-assist-normal-chat-and-manual-record-draft.md`

## Contracts/DB changes
- None.

## User-visible impact
- Assistant behaves closer to normal AI consultation before recording.
- Record draft appears only on explicit user action.

## Verification Steps
1. App build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`
2. Server syntax:
   - `node --check server.js`
   - Result: `SERVER_CHECK:OK`
3. Proxy runtime refresh:
   - `./manage_launchd_proxy.sh restart`
   - `curl http://127.0.0.1:8787/healthz`
   - Result: `{"status":"ok"}`

## Rollback Notes
- Revert files listed in `Files Changed`.

# Change-084 — Assist Surface Session Workspace and Confirm-to-Record

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: iOS/AssistFlow/UI/ViewModel
- Related Skills: capture-ui, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Changed Assist surface behavior from "history list" to "current conversation workspace":
  - no longer renders persisted assistant records in Assist surface.
  - displays only current in-memory conversation messages.
- Updated assist input flow:
  - sending in Assist mode no longer writes `CaptureEntity` immediately.
  - now creates in-memory user/assistant messages and a pending draft card.
- Added explicit confirmation action:
  - `记录到记录页`: converts current assist draft into one log record (`mode=.log`) and saves it.
  - after saving, assist session is reset to a fresh blank session.
- Added session controls:
  - `重开会话`: clears current in-memory assist session.

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-03-08_session-037.md`
- `Docs/05_Changes/Change-084-assist-surface-session-workspace-and-confirm-to-record.md`

## Contracts/DB changes
- None.
- Existing historical assist records remain in DB but are no longer shown in Assist surface.

## User-visible impact
- Assist surface now behaves like a chat workspace (single active session).
- Record list stays cleaner; only confirmed outputs appear in record workflow.

## Verification Steps
1. Build:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
   - Result: `EXIT:0`
2. Manual:
   - Switch to `助手` and send text, verify only session bubbles appear.
   - Verify draft card shows `记录到记录页`.
   - Tap `记录到记录页`, confirm Assist view clears and Record view contains a new log entry.

## Rollback Notes
- Revert files listed in `Files Changed`.

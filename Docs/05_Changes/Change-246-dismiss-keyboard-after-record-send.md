---
date: 2026-05-12
owner: Codex
scope: iOS/RecordFeed/Keyboard
status: Done
related_session: ../04_Sessions/2026-05-12_session-001.md
---

# Change 246 - Dismiss Keyboard After Record Send

## What Changed
- Added a view-level `sendCurrentInput()` wrapper in `RecordFeedScreen`.
- The bottom input bar now calls `sendCurrentInput()` instead of directly calling `viewModel.addCaptureFromInput`.
- After a non-empty send attempt, the existing `dismissKeyboard()` helper clears search/input focus and asks UIKit to resign first responder.

## Files Changed
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Docs/04_Sessions/2026-05-12_session-001.md`
- `Docs/05_Changes/Change-246-dismiss-keyboard-after-record-send.md`
- `Docs/VERIFICATION_BACKLOG.md`

## User-Visible Impact
- When the user writes a text record and taps send, the keyboard should automatically collapse once the send action has been performed.
- The new record remains visible without the keyboard covering the bottom of the screen.
- Empty input remains disabled by the existing input bar behavior.

## Verification
- Debug build passed on iPhone 17 Pro Max simulator.
- Full `xcodebuild test` passed on iPhone 17 Pro Max simulator.

## Manual Verification Steps
1. Open the record page.
2. Tap the text input field and type a short record.
3. Tap the send arrow.
4. Expected: the record is added and the keyboard collapses automatically.
5. Switch to Assistant mode, type a short message, send it, and confirm the input remains usable afterward.

## Rollback Notes
- Revert this change to restore the previous behavior where sending only cleared the text but did not explicitly release keyboard focus.
- No data model, API, AI, voice transcription, or persistence changes are involved.

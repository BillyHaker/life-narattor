# Change 234 - Record Status Copy

## Metadata
- Date: 2026-05-06
- Owner: Codex
- Scope: iOS/Copy
- Status: Done
- Related ADR: None

## Goal
Replace the successful record status copy `已接住` with clearer wording `已记录`.

## Files Changed
- `Life Narattor/Models/VoiceModels.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/Views/CaptureCardView.swift`
- `Docs/04_Sessions/2026-05-06_session-002.md`
- `Docs/05_Changes/Change-234-record-status-copy.md`

## Implementation
- Updated successful transcription and record-card status strings to `已记录`.
- Left failed-understanding copy unchanged.

## User-visible impact
- Newly created records now show `已记录` before they are split/organized.

## Verification
- `rg` confirmed no primary success status still returns `已接住`.
- `git diff --check` passed.
- Xcode MCP `BuildProject` passed.

## Manual Verification
- Add a text record and verify the chip says `已记录`.
- Add a voice record and verify completed status says `已记录`.

## Rollback
- Revert this commit to restore the previous copy.

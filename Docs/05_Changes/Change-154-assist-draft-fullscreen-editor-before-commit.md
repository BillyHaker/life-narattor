# Change 154 - Assistant draft full-screen editor before commit

## Summary
Changed the assistant "整理为记录" flow from an inline confirm card to a full-screen editable draft. Users now review and lightly edit the record before confirming it into the record list. Split and tag generation still happen only after confirmation.

## What changed
- Added a full-screen `AssistDraftEditorScreen` with editable title and body.
- Added view model helpers to derive editable body text from `AssistArchivePayload`, save draft edits, and commit edited drafts.
- Replaced the inline `AssistDraftConfirmCard` flow in `RecordFeedScreen` with a full-screen cover.
- `重新整理` inside the editor now dismisses and regenerates the draft instead of leaving stale draft content on screen.

## Files
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Views/AssistDraftEditorScreen.swift`

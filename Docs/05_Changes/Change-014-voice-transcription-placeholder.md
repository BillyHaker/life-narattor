# Change-014 — Voice Recording/Transcription Placeholder Flow

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / DB
- Related Skills:
  - Skills/speech-transcription/SKILL.md
- Related ADRs: ADR-006
- Status: Done

## What changed
- Added:
  - Voice/transcription fields on CaptureEntity and CaptureItem.
  - Recording chip UI (start/stop/cancel).
  - Placeholder transcription flow and retry.
  - Raw tab shows transcript and playback placeholders.
- Updated:
  - Capture card displays transcription status and retry.
  - Record preview includes a voice capture.
- Removed:
  - Audio overlay placeholder.

## Files / Modules touched
- Life Narattor/Life Narattor/Models/VoiceModels.swift
- Life Narattor/Life Narattor/Models/CaptureItem.swift
- Life Narattor/Life Narattor/Data/CaptureEntity.swift
- Life Narattor/Life Narattor/Data/PersistenceController.swift
- Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Life Narattor/Views/RecordingChipView.swift
- Life Narattor/Life Narattor/Views/CaptureCardView.swift
- Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift

## DB / API changes
- DB migration:
  - Added CaptureEntity fields: inputType, audioPath, transcriptText, transcriptionStatus.
- API contract:
  - None.

## User-visible impact
- Users can start a voice capture, see recording chip, and see transcription status update.

## Verification
- Steps:
1) Build the project.
2) Tap mic to start recording; recording chip appears.
3) Tap Stop; capture shows “正在转写…”, then “转写完成”.
4) Open capture detail Raw tab; transcript placeholder is shown.

## Rollback plan
- Revert capture schema fields and remove recording chip/transcription UI.

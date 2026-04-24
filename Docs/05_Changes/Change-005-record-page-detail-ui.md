# Change-005 — Record Page Detail Sheet, Processing States, and Audio Overlay

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI/DB
- Related Skills:
  - Skills/capture-ui/SKILL.md
  - Skills/ia-navigation/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Capture detail sheet (clean/raw/atoms tabs).
  - Atom rows with tag chips and actions menu.
  - Tag selection sheet (placeholder) and audio recorder overlay (placeholder).
- Updated:
  - Capture cards show processing state and expand toggle.
  - Record feed opens detail sheet and shows audio overlay.
  - Capture schema adds atomsCount and processingState.
- Removed:
  - None.

## Files / Modules touched
- Life Narattor/Life Narattor/Models/CaptureItem.swift
- Life Narattor/Life Narattor/Data/CaptureEntity.swift
- Life Narattor/Life Narattor/Data/PersistenceController.swift
- Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/Life Narattor/Views/AddTagSheet.swift
- Life Narattor/Life Narattor/Views/AudioRecorderOverlayView.swift
- Life Narattor/Life Narattor/Views/CaptureCardView.swift
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift

## DB / API changes
- DB migration:
  - Added CaptureEntity.atomsCount and CaptureEntity.processingState.
- API contract:
  - None.

## User-visible impact
- Record page now supports capture detail sheet, atom list placeholders, and tag sheet.
- Processing status and expand toggle appear under capture cards.
- Audio recorder overlay appears on mic tap (placeholder).

## Verification
- Steps:
1) Build the project.
2) Render RecordFeedScreen preview and tap a card to view the detail sheet.
3) Tap mic to show audio overlay and dismiss it.

## Rollback plan
- Revert files listed above and remove atomsCount/processingState from persistence model.

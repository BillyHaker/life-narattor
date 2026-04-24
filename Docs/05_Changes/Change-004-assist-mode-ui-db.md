# Change-004 — Assist Mode Toggle, Archive Card UI, and Artifacts Storage

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI/DB/API/AI
- Related Skills:
  - Skills/capture-ui/SKILL.md
  - Skills/ai-interaction/SKILL.md
  - Skills/database-schema/SKILL.md
- Related ADRs: ADR-002
- Status: Done

## What changed
- Added:
  - Assist Archive payload model and card UI.
  - Artifacts persistence entity for Assist Archive storage.
  - Log/Assist mode toggle in input bar.
- Updated:
  - Capture feed view model to branch Log vs Assist flows.
  - Capture cards to display Assist Archive card when available.
  - Record feed preview data to include Assist sample.
- Removed:
  - None.

## Files / Modules touched
- Life Narattor/Life Narattor/AI/AIService.swift
- Life Narattor/Life Narattor/Models/AssistArchivePayload.swift
- Life Narattor/Life Narattor/Models/CaptureItem.swift
- Life Narattor/Life Narattor/Data/PersistenceController.swift
- Life Narattor/Life Narattor/Data/ArtifactEntity.swift
- Life Narattor/Life Narattor/Data/CaptureEntity.swift
- Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Life Narattor/Views/CaptureInputBarView.swift
- Life Narattor/Life Narattor/Views/CaptureCardView.swift
- Life Narattor/Life Narattor/Views/AssistArchiveCardView.swift
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift

## DB / API changes
- DB migration:
  - Added ArtifactEntity and CaptureEntity.mode attribute.
- API contract:
  - Added Assist Archive mock to AIService.

## User-visible impact
- Record input bar now supports Log/Assist mode.
- Assist mode shows Reply + Archive Card with Save/Edit/End actions.

## Verification
- Steps:
1) Build the project.
2) Render RecordFeedScreen preview and confirm Assist card renders under a capture.
3) Run app, switch to Assist, send a capture, and verify Assist card shows.

## Rollback plan
- Revert files listed above and remove ArtifactEntity from persistence model.

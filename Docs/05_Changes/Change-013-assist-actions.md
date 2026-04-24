# Change-013 — Assist Save/Edit/End with Persistence

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / DB / AI
- Related Skills:
  - Skills/assist-archive-card/SKILL.md
  - Skills/ai-interaction/SKILL.md
  - Skills/tags/SKILL.md
  - Skills/atomization/SKILL.md
- Related ADRs: ADR-005
- Status: Done

## What changed
- Added:
  - Assist archive status (draft/saved/ended) persisted in ArtifactEntity.
  - Assist edit sheet for Archive Card fields.
  - Save/Edit/End actions wired to persistence and atom/tag creation.
- Updated:
  - Capture card renders Assist actions with saved/ended states.
  - AtomTagStore can create atoms from Assist Archive and apply tag suggestions.
  - Assist tag suggestions now include optional score.
- Removed:
  - Placeholder buttons with no behavior.

## Files / Modules touched
- Life Narattor/Life Narattor/Models/AssistArchivePayload.swift
- Life Narattor/Life Narattor/Data/ArtifactEntity.swift
- Life Narattor/Life Narattor/Data/PersistenceController.swift
- Life Narattor/Life Narattor/Data/AtomTagStore.swift
- Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Life Narattor/Views/AssistArchiveCardView.swift
- Life Narattor/Life Narattor/Views/AssistArchiveEditSheet.swift
- Life Narattor/Life Narattor/Views/CaptureCardView.swift
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift
- Life Narattor/Life Narattor/AI/AIService.swift

## DB / API changes
- DB migration:
  - Added ArtifactEntity.status field.
- API contract:
  - Assist tag suggestions can include score.

## User-visible impact
- Assist cards can be saved as record (atoms + tags), edited, or ended.
- Saved cards show a confirmation state; ended cards hide the assist UI.

## Verification
- Steps:
1) Build the project.
2) Create an Assist capture and wait for the card.
3) Tap Save as Record; verify atoms appear in detail and tags assigned.
4) Tap Edit; change title and confirm it persists.
5) Tap End; assist card should hide.

## Rollback plan
- Revert files above and remove ArtifactEntity.status from the model.

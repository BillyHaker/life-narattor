# Change-012 — Atom/Tag Persistence and Record Detail Editing

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / DB
- Related Skills:
  - Skills/atomization/SKILL.md
  - Skills/tags/SKILL.md
  - Skills/database-schema/SKILL.md
- Related ADRs: ADR-004
- Status: Done

## What changed
- Added:
  - CoreData entities for atoms, tags, and atom-tag links.
  - AtomTagStore for fetching and editing atoms/tags.
  - Atom detail sheet and tag picker with real persistence.
- Updated:
  - Capture detail sheet to load real atoms and allow tagging.
  - Capture feed to stub-generate atoms after quick ack.
  - Record preview data to seed atoms/tags.
- Removed:
  - Mock atom generation in detail sheet.

## Files / Modules touched
- Life Narattor/Life Narattor/Data/AtomEntity.swift
- Life Narattor/Life Narattor/Data/TagEntity.swift
- Life Narattor/Life Narattor/Data/AtomTagEntity.swift
- Life Narattor/Life Narattor/Data/AtomTagStore.swift
- Life Narattor/Life Narattor/Data/PersistenceController.swift
- Life Narattor/Life Narattor/Models/AtomItem.swift
- Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/Life Narattor/Views/AtomDetailSheet.swift
- Life Narattor/Life Narattor/Views/AddTagSheet.swift
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift

## DB / API changes
- DB migration:
  - Added AtomEntity, TagEntity, AtomTagEntity; CaptureEntity now links to atoms by captureID.
- API contract:
  - None.

## User-visible impact
- Record detail shows persisted atoms and allows tag assignment and atom edits.

## Verification
- Steps:
1) Build the project.
2) Create a capture and open detail; atoms should appear after QuickAck.
3) Add a tag to an atom and reopen detail to confirm persistence.

## Rollback plan
- Remove new entities and revert CaptureDetailSheet/AddTagSheet to mock data.

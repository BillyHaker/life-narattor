# Change-006 — Enable Lightweight CoreData Migration

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DB
- Related Skills:
  - Skills/database-schema/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Lightweight migration options for CoreData persistent store.
- Updated:
  - None.
- Removed:
  - None.

## Files / Modules touched
- Life Narattor/Life Narattor/Data/PersistenceController.swift

## DB / API changes
- DB migration:
  - Enables automatic migration when schema changes.
- API contract:
  - None.

## User-visible impact
- Prevents launch-time failures when the CoreData model changes.

## Verification
- Steps:
1) Build the project.
2) Launch the app with an existing store; confirm it opens.

## Rollback plan
- Remove the migration flags from PersistenceController.

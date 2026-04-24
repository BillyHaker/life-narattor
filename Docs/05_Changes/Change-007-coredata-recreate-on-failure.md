# Change-007 — Recreate CoreData Store on Load Failure (Dev Safety)

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
  - Fallback to destroy and recreate persistent store when load fails.
- Updated:
  - None.
- Removed:
  - None.

## Files / Modules touched
- Life Narattor/Life Narattor/Data/PersistenceController.swift

## DB / API changes
- DB migration:
  - Adds destructive fallback for development to recover from schema mismatch.
- API contract:
  - None.

## User-visible impact
- Prevents crash/white screen by resetting corrupted/incompatible local store.

## Verification
- Steps:
1) Build the project.
2) Launch app with an incompatible store; expect auto-reset and app opens.

## Rollback plan
- Remove the destroy-and-recreate fallback in PersistenceController.

# ADR-001 — CoreData for V1 Local Persistence

## Meta
- Date: 2026-03-03
- Status: Accepted
- Decision owners: Codex
- Scope: DB
- Related Skills: Skills/database-schema/SKILL.md
- Related files/modules: Life Narattor/Life Narattor/Data/PersistenceController.swift

## Context
- Need a minimal, on-device persistence layer to store captures and QuickAck fields.
- Project currently has no DB layer or external dependencies.
- Must keep raw data and support future expansion toward the V1 schema.

## Decision
- We will use CoreData with a programmatic `NSManagedObjectModel` for the V1 skeleton.

## Rationale
- CoreData ships with iOS and avoids adding third-party dependencies for V1.
- Provides a clear migration path to a fuller schema later.
- Good fit for simple capture storage and list queries.

## Consequences
- Positive:
  - Minimal setup; no extra packages.
  - Works offline and fits the V1 capture feed requirement.
- Negative:
  - Programmatic model is less ergonomic than `.xcdatamodeld`.
  - Schema changes must be coordinated carefully.
- Future migration path:
  - Move to SQLite/GRDB by introducing a data access layer that mirrors the current entity fields, then migrate records via a one-time export/import.

## Validation
- Create a capture, relaunch app, confirm capture persists in feed.

## Links
- Session log: Docs/04_Sessions/2026-03-03_session-001.md
- Change log: Docs/05_Changes/Change-001-v1-shell-capture-db-ai.md

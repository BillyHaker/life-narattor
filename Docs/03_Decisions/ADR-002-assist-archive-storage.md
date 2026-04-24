# ADR-002 — Assist Archive Storage in Artifacts Table

## Meta
- Date: 2026-03-04
- Status: Accepted
- Decision owners: Codex
- Scope: DB / AI
- Related Skills:
  - Skills/ai-interaction/SKILL.md
  - Skills/database-schema/SKILL.md
- Related files/modules:
  - Life Narattor/Life Narattor/Data/PersistenceController.swift
  - Life Narattor/Life Narattor/Data/ArtifactEntity.swift

## Context
- Assist mode now requires saving an Archive Card (Reply + Card) as a durable asset.
- Current persistence only stores Capture entities.
- Updated skills recommend an artifacts table for Assist archive cards.

## Decision
- We will add an `ArtifactEntity` (artifacts table) and store Assist Archive payload JSON in `contentJSON` keyed by `sourceCaptureID`.

## Rationale
- Aligns with Skills/database-schema recommendation.
- Keeps Assist payload encapsulated and easily portable.
- Allows future migration to SQLite/GRDB while preserving structure.

## Consequences
- Positive:
  - Assist payloads are durable and linked to captures.
  - Can extend to other artifact types without touching Capture schema.
- Negative:
  - Programmatic CoreData schema grows in complexity.
- Future migration path:
  - Export artifacts table to SQLite with the same fields; decode JSON to structured rows later if needed.

## Validation
- Create an Assist capture and verify the Archive Card renders from persisted artifact data.

## Links
- Session log: Docs/04_Sessions/2026-03-04_session-001.md
- Change log: Docs/05_Changes/Change-004-assist-mode-ui-db.md

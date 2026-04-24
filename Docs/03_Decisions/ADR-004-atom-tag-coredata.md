# ADR-004 — CoreData Entities for Atoms and Tags

## Meta
- Date: 2026-03-04
- Status: Accepted
- Decision owners: Codex
- Scope: DB / UI
- Related Skills:
  - Skills/atomization/SKILL.md
  - Skills/tags/SKILL.md
  - Skills/database-schema/SKILL.md
- Related files/modules:
  - Life Narattor/Life Narattor/Data/PersistenceController.swift
  - Life Narattor/Life Narattor/Data/AtomEntity.swift
  - Life Narattor/Life Narattor/Data/TagEntity.swift
  - Life Narattor/Life Narattor/Data/AtomTagEntity.swift

## Context
- Record detail currently uses mock atoms and placeholder tags.
- V1 requires atom editing and tag assignment with persistence.

## Decision
- Add CoreData entities for atoms, tags, and atom-tag links using a simple join table.

## Rationale
- Aligns with Skills/database-schema and enables atom/tag editing in Record detail.
- Keeps persistence local and simple while avoiding premature relationships.

## Consequences
- Positive:
  - Atoms and tags are queryable and editable.
  - Enables tag picker and atom detail edit.
- Negative:
  - Programmatic model grows; migration requires care.

## Validation
- Create a capture, open detail, see atoms persisted; add/remove tag persists.

## Links
- Session log: Docs/04_Sessions/2026-03-04_session-009.md
- Change log: Docs/05_Changes/Change-012-atom-tag-persistence.md

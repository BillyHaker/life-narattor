# ADR-005 — Persist Assist Archive Status in ArtifactEntity

## Meta
- Date: 2026-03-04
- Status: Accepted
- Decision owners: Codex
- Scope: DB / UI
- Related Skills:
  - Skills/assist-archive-card/SKILL.md
  - Skills/ai-interaction/SKILL.md
- Related files/modules:
  - Life Narattor/Life Narattor/Data/ArtifactEntity.swift
  - Life Narattor/Life Narattor/Data/PersistenceController.swift

## Context
- Assist card needs Save/Edit/End actions with persistent state.
- Current ArtifactEntity stores payload but not status.

## Decision
- Add `status` to ArtifactEntity with values: draft | saved | ended.

## Rationale
- Keeps Assist state durable across app launches.
- Enables hiding or marking completed assist cards without deleting data.

## Consequences
- Positive:
  - Persistent assist lifecycle and clear UI rendering.
- Negative:
  - CoreData schema change; may require migration/reset in dev.

## Validation
- Ended assist cards no longer render; saved cards show saved state.

## Links
- Session log: Docs/04_Sessions/2026-03-04_session-010.md
- Change log: Docs/05_Changes/Change-013-assist-actions.md

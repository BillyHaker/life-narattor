# ADR-010 — Record schema and revision model

## Meta
- Date: 2026-03-09
- Status: Accepted
- Owners: Codex
- Scope: Data / CoreData / Record modeling / Rendering
- Related Skills: record-modeling, database-schema, ai-interaction
- Related files/modules: Skills/record-modeling/SKILL.md, Skills/record-modeling/references/knowledge-card-integration.md

## Context

Life Narrator currently has:
- `CaptureEntity` for source input
- `ArtifactEntity` for assorted JSON artifacts
- `AtomEntity` and tag-related entities for atomization and retrieval

This is sufficient for early prototyping, but it is not an ideal long-term storage shape for canonical records because:
- records and revisions are not first-class entities
- multiple unrelated semantics are mixed into `ArtifactEntity`
- assistant notes, daily notes, and imported knowledge cards need one common record backbone
- future style upgrades should not require rewriting source data

The project currently has no production data that must be preserved, so schema change cost is minimal.

## Alternatives

1. Continue using `ArtifactEntity + contentJSON` as the main record store
- Pros: minimal immediate implementation work
- Cons: query debt, schema ambiguity, hard-to-maintain revision model, poor long-term clarity

2. Keep `CaptureEntity` as both source layer and final record layer
- Pros: fewer entities
- Cons: source input, process state, and final semantics stay coupled; poor fit for imported knowledge cards

3. Introduce a dedicated record schema now
- Pros: stable long-term backbone, cleaner revision model, better compatibility with assistant records and imported knowledge cards
- Cons: more upfront schema work

## Decision

Adopt a dedicated record schema now:

- `CaptureEntity` remains the source-layer entity
- Add `RecordEntity` as the canonical user-visible record header
- Add `RecordRevisionEntity` as the canonical versioned semantic payload store
- Add `RecordTagLinkEntity` for record-level tagging independent of atomization

Use a typed structured payload (`record_payload_v1`) inside `RecordRevisionEntity.payloadJSON`.

Rendered note text is derived and optionally cached, but it is not the source of truth.

## Rationale

- There is no migration burden yet, so delaying the schema would only create unnecessary future debt.
- A dedicated record header + revision model is better aligned with:
  - assistant-generated notes
  - imported knowledge cards
  - future style upgrades
  - revision traceability
  - self-model ingestion
- Record kinds (`log / action / insight / decision`) provide enough visual specialization without fragmenting the database model.
- Versioned payloads and renderers allow format evolution without rewriting raw captures.

## Consequences

### Positive
- Record semantics become first-class and queryable.
- Rendering can evolve independently from semantic storage.
- External study / reading tools can import directly into the same canonical model.
- Record revisions are traceable and stable.

### Negative
- Requires explicit schema implementation work now.
- Some existing assist-storage logic will need to move away from using `ArtifactEntity` as the main content store.

## Validation

The design is considered valid if the implementation can satisfy all of the following:
- One assistant-generated action note can be stored as `RecordEntity + RecordRevisionEntity`.
- One imported knowledge card can be stored through the same path with `kind = insight`.
- A record can be re-rendered into different visual note styles without changing source capture data.
- A record can be revised while preserving original `createdAt` and revision lineage.

## Links

- Skill: `Skills/record-modeling/SKILL.md`
- Reference: `Skills/record-modeling/references/knowledge-card-integration.md`
- Session: `Docs/04_Sessions/2026-03-09_session-049.md`
- Change: `Docs/05_Changes/Change-096-record-schema-decision-and-formal-entity-plan.md`

# ADR-009 — AI atomization + suggested tags with AtomTag isSuggested flag

## Meta
- Date: 2026-03-05
- Status: Accepted
- Owners: Codex
- Scope: AI / Atomization / Tags / CoreData
- Related Skills: ai-interaction, atomization, tags, privacy-redaction-standard
- Related files/modules: Life Narattor/AI/AIService.swift, Life Narattor/Data/AtomTagStore.swift, Life Narattor/Data/PersistenceController.swift, Life Narattor/Data/AtomTagEntity.swift, Life Narattor/Views/CaptureDetailSheet.swift

## Context
We need reliable AI atomization and tag suggestion with clear debugging. The tags skill requires AI suggestions to be shown as “建议” and confirmed by the user. The current data model cannot represent suggested vs confirmed tags, and atomization is rule-based only.

## Alternatives
1) Keep rule-based atomization and skip AI suggestions (insufficient quality and no debugging).
2) Store suggestions only in logs/DevTools (not user-visible, violates tags skill).
3) Add a new suggestion table (larger schema change + more UI work).

## Decision
Add AI-driven atomization and tag suggestions, and extend AtomTagEntity with a boolean `isSuggested` to mark AI-suggested tags. Suggested tags render with a “建议” pill and become confirmed when tapped. Hidden tags are stored as non-user-visible tags and excluded from UI and tag search.

## Rationale
- Aligns with atomization and tags skills without introducing a new entity.
- Keeps changes minimal while enabling a visible confirmation step.
- Allows hidden tags for internal use without leaking into UI.

## Consequences
- CoreData schema changes (AtomTagEntity gains `isSuggested`).
- UI must handle suggested tag display and confirmation.
- Hidden tags will not appear in Tag Manager or search filters by default.

## Validation
- Manual: create a new capture, wait for AI atomization, check Atoms tab shows suggested tag with “建议”, tap to confirm and verify tag becomes normal.
- DevTools: AI Debug shows request/response for atomize and tag_suggest.

## Links (session/change)
- Session: Docs/04_Sessions/2026-03-05_session-043.md
- Change: Docs/05_Changes/Change-048-ai-atomization-debug.md

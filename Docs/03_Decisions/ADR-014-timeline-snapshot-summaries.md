---
date: 2026-04-26
owner: Codex
status: Accepted
scope: UX/UI/AI
related_changes:
  - Docs/05_Changes/Change-202-timeline-snapshot-summaries-phase-1.md
---

# ADR-014 — Timeline Summaries Should Be Snapshot-Based, Not Realtime

## Context
Timeline day cards are a live browsing surface, but users wanted the summary area to provide a calmer, more stable reference. Realtime summary generation creates the wrong expectation: that today, this week, and this month are being continuously interpreted as the user records events.

## Alternatives Considered
1. Keep the current realtime count-based summary copy.
2. Compute an AI summary every time Timeline opens.
3. Introduce persisted timeline summary snapshots for completed periods and refresh them when stale.

## Decision
Choose option 3.

Timeline summaries now use persisted snapshots for:
- yesterday
- past 7 days
- past 30 days

The live day list remains realtime, but the storyline summary comes from completed periods.

## Rationale
- Better matches the product intent: reference and reflection instead of constant live interpretation.
- Avoids fragile dependence on exact background execution times on iOS.
- Creates a reusable summary layer that can later be upgraded with background scheduling.
- Keeps the UI honest: today is still forming, yesterday is complete enough to summarize.

## Consequences
- Timeline now has a distinct snapshot layer persisted in `ArtifactEntity`.
- Summary labels no longer mirror the visible browse scope exactly.
- Refresh logic must check staleness and regenerate on foreground/open as a fallback.
- Future work may extend the same pattern to dedicated review pages and optional background tasks.

## Validation
- Build passes.
- Unit tests pass.
- Timeline summary labels and copy reflect snapshot semantics instead of realtime count-only blurbs.

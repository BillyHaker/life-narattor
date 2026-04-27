---
date: 2026-04-25
owner: Codex
status: Accepted
scope: UX/UI
related_changes:
  - Docs/05_Changes/Change-201-weekly-monthly-range-review-redesign.md
---

# ADR-013 — Weekly/Monthly Review Should Be Range-First, Not Day-List-First

## Context
`本周回顾` and `本月回顾` already retrieved period-wide materials, but the screen structure still centered a day list. That made the experience feel like a date browser with a paragraph on top, rather than an actual review of the whole week or month.

## Alternatives Considered
1. Keep the existing day list and only improve the top summary.
2. Replace the page with a pure AI long-form paragraph.
3. Make the page range-first: overview, structural signals, evidence, follow-up prompts, and source days last.

## Decision
Choose option 3.

Weekly/monthly review surfaces should present the whole period first and only expose day-level navigation as traceability support. The page should answer “what happened in this stretch of time?” before it answers “which specific day should I open?”.

## Rationale
- Matches the product goal of AI-native review rather than a traditional filtered list.
- Reduces cognitive load by keeping dates and raw evidence as supporting material.
- Keeps traceability intact because source days are still available at the bottom.
- Gives weekly/monthly/custom range reviews a reusable structure going forward.

## Consequences
- Weekly and monthly screens now need shared range-review view data instead of directly rendering `TimelineDay` lists.
- Current calendar week/month boundaries become the default semantics, replacing rolling 7/30 day windows for these two screens.
- Future custom range review should reuse the same range-first structure.

## Validation
- Build passes.
- Unit tests pass.
- Screen copy no longer includes stale day-list-first labels such as `本周片段` / `本月片段` or rolling-window labels in the redesigned screens.

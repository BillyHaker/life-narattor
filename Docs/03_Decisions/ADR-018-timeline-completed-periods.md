# ADR-018 - Timeline Uses Completed Periods for Review Ranges

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Timeline/UX
- Status: Accepted

## Context
Timeline review cards are intended to summarize completed periods: yesterday, the last completed 7 days, and the last completed 30 days. The UI labels already communicate this mental model, but the lower day list previously used live ranges such as today and now-minus-seven-days.

This caused confusing states where the top story card could say there was no material for yesterday while the lower list showed today's records.

## Alternatives
- Keep live ranges and rename labels back to today/current week/current month.
- Keep completed-period snapshot ranges but keep live day lists.
- Align both snapshot and day lists to completed periods.

## Decision
Use completed periods consistently across Timeline summaries and lower day lists.

## Rationale
The Timeline page is a reflective surface rather than a live feed. Completed periods create more stable AI summaries, avoid partial-day churn, and match the product direction of nightly/periodic review.

## Consequences
- `昨日` no longer shows today's records.
- `7天回顾` and `30天回顾` exclude today.
- Users still record today from the Record tab; Timeline presents what has already settled.

## Validation
- Verify that top snapshot counts and lower day cards refer to the same period.
- Verify that empty states do not imply records are missing from another period.

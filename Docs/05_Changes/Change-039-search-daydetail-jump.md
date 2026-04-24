# Change-039 — Search day detail jump

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI
- Related Skills: search, timeline-browse
- Related ADRs:
- Status: Done

## What changed
- Search results date headers now jump to Day Detail for that date.
- Day detail is built from grouped search results (highlights + capture IDs).

## Files touched
- `Life Narattor/Life Narattor/Screens/SearchScreen.swift`

## Contracts/DB changes
- None.

## User-visible impact
- Users can navigate from Search results by date into the Day Detail screen.

## Verification steps
1) Open Search and enter a query that yields results.
2) Tap a date header and confirm Day Detail opens for that date.

## Rollback plan
- Revert edits in `Life Narattor/Life Narattor/Screens/SearchScreen.swift`.

# Change-015 — Timeline Home + Day Detail UI

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Navigation
- Related Skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/daily-narrative-two-layer/SKILL.md
  - Skills/ia-navigation/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Timeline scope switcher (today/week/month/custom).
  - Timeline day cards with highlights and CTA.
  - Day detail screen with narrative, AI comment styles, records, and sources sections.
- Updated:
  - Timeline models for scope and day items.
- Removed:
  - Placeholder Timeline screen.

## Files / Modules touched
- Life Narattor/Life Narattor/Models/TimelineModels.swift
- Life Narattor/Life Narattor/Screens/TimelineScreen.swift
- Life Narattor/Life Narattor/Screens/DayDetailScreen.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- Timeline tab now shows day cards and navigates to a Day Detail view.

## Verification
- Steps:
1) Build the project.
2) Open Timeline tab; verify scope switcher and day cards.
3) Tap a day card to open Day Detail; verify narrative and comment sections.

## Rollback plan
- Revert TimelineScreen and remove DayDetail screen.

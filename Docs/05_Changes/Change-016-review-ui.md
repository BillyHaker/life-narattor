# Change-016 — Review Home + Weekly/Monthly Screens

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Navigation
- Related Skills:
  - Skills/review-memory/SKILL.md
  - Skills/daily-narrative-two-layer/SKILL.md
  - Skills/ia-navigation/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Weekly review detail screen.
  - Monthly review detail screen.
  - Review models for periods and snippets.
- Updated:
  - Review home with CTAs and memory snippets.
- Removed:
  - Placeholder Review screen.

## Files / Modules touched
- Life Narattor/Life Narattor/Models/ReviewModels.swift
- Life Narattor/Life Narattor/Screens/ReviewHomeScreen.swift
- Life Narattor/Life Narattor/Screens/WeeklyReviewScreen.swift
- Life Narattor/Life Narattor/Screens/MonthlyReviewScreen.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- Review tab shows CTA buttons, memory snippets, and navigates to weekly/monthly detail screens.

## Verification
- Steps:
1) Build the project.
2) Open Review tab and tap Weekly/Monthly buttons.
3) Verify narrative + AI comment sections render.

## Rollback plan
- Revert ReviewHomeScreen and remove weekly/monthly screens.

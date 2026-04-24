# Change-017 — Projects List + Project Detail UI

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Navigation
- Related Skills:
  - Skills/project-review/SKILL.md
  - Skills/ia-navigation/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Project list cards and navigation to detail.
  - Project detail screen with timeline/review tabs.
- Updated:
  - Project models for list/detail UI.
- Removed:
  - Placeholder Projects screen.

## Files / Modules touched
- Life Narattor/Life Narattor/Models/ProjectModels.swift
- Life Narattor/Life Narattor/Screens/ProjectsListScreen.swift
- Life Narattor/Life Narattor/Screens/ProjectDetailScreen.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- Projects tab now lists sample projects and opens project detail with timeline/review tabs.

## Verification
- Steps:
1) Build the project.
2) Open Projects tab and tap a project.
3) Switch between timeline and review tabs in the detail screen.

## Rollback plan
- Revert ProjectsListScreen and remove ProjectDetailScreen.

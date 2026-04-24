# Change-019 — Search CoreData queries and states

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Data
- Related Skills:
  - Skills/search/SKILL.md
  - Skills/database-schema/SKILL.md
  - Skills/tags/SKILL.md
- Related ADRs: None
- Status: Done

## What changed
- Search now queries CoreData for captures, atoms, and tags.
- Results group by date and open the correct detail sheets.
- Added date range picker, empty/loading/error states, and tag-based filtering.

## Files touched
- Life Narattor/Life Narattor/Screens/SearchScreen.swift
- Life Narattor/Life Narattor/Models/SearchModels.swift

## Contracts/DB changes
- None.

## User-visible impact
- Search works offline using local data, filters by tags and date range, and surfaces atom/capture results.

## Verification steps
1) Run the app and open Review → Search.
2) Enter a keyword that exists in a capture clean/raw text; results show with time and snippet.
3) Enter a keyword that exists in atom content; results show atom cards with tag pills.
4) Tap a result card: capture opens CaptureDetailSheet; atom opens AtomDetailSheet.
5) Tap the date range pill → choose “最近7天”; results update.
6) Tap tag pills → query updates and results refresh.
7) Clear query and filters → Search shows recent section without results; no crash.

## Rollback plan
- Revert `Life Narattor/Life Narattor/Screens/SearchScreen.swift` and `Life Narattor/Life Narattor/Models/SearchModels.swift`.

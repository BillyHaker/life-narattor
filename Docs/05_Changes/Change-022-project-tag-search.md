# Change-022 — Project tag opens Search

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Navigation
- Related Skills:
  - Skills/search/SKILL.md
  - Skills/tags/SKILL.md
  - Skills/ia-navigation/SKILL.md
- Related ADRs: None
- Status: Done

## What changed
- Project detail header tag now opens Search with the project name and project filter.

## Files touched
- Life Narattor/Life Narattor/Screens/ProjectDetailScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Tapping the project tag pill on the Project detail screen jumps to Search filtered by that project.

## Verification steps
1) Open Projects → open a project.
2) Tap the “项目” pill under the header.
3) Search opens with query prefilled as the project name and filter set to 项目.

## Rollback plan
- Revert `Life Narattor/Life Narattor/Screens/ProjectDetailScreen.swift`.

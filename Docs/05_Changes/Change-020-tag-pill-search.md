# Change-020 — Tag pills open Search

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
- Tag pills in Atom rows now open Search with the tag prefilled.
- Search can initialize with a preselected filter derived from tag type.

## Files touched
- Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/Life Narattor/Models/SearchModels.swift
- Life Narattor/Life Narattor/Screens/SearchScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Tapping any tag pill in Atom details now jumps to Search filtered by that tag.

## Verification steps
1) Open a capture detail → 拆分 tab → tap any tag pill.
2) Search opens with the tag name prefilled.
3) If tag type is 项目/主题/人物, the corresponding filter pill is selected.

## Rollback plan
- Revert changes in `Life Narattor/Life Narattor/Views/CaptureDetailSheet.swift`, `Life Narattor/Life Narattor/Models/SearchModels.swift`, and `Life Narattor/Life Narattor/Screens/SearchScreen.swift`.

# Change-024 — Day detail tag pills open Search

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
- Added tag pills in Day detail sources section that open Search with tag query and filter.

## Files touched
- Life Narattor/Life Narattor/Screens/DayDetailScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Users can tap tags in a day’s sources to jump into Search.

## Verification steps
1) Open Timeline → select a day.
2) Scroll to 引用来源 section.
3) Tap any tag pill → Search opens with prefilled query and filter.

## Rollback plan
- Revert `Life Narattor/Life Narattor/Screens/DayDetailScreen.swift`.

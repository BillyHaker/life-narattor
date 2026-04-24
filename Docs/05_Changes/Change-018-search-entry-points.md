# Change-018 — Search entry points and tag taps

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Search
- Related Skills:
  - Skills/search/SKILL.md
  - Skills/ia-navigation/SKILL.md
- Related ADRs: None
- Status: Done

## What changed
- Added Review top-right search entry point.
- Memory snippet cards now open Search with a prefilled query.
- Tag pills in Search results now set the query when tapped.

## Files touched
- Life Narattor/Life Narattor/Screens/ReviewHomeScreen.swift
- Life Narattor/Life Narattor/Screens/SearchScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Users can open Search from Review and jump from memory snippets to a filtered search.

## Verification steps
1) Run the app and open the Review tab.
2) Tap the top-right magnifying glass → Search screen appears.
3) Tap a memory snippet card → Search opens with the snippet text prefilled.
4) On Search, tap a tag pill in a result card → search input updates to the tag.

## Rollback plan
- Revert changes in `Life Narattor/Life Narattor/Screens/ReviewHomeScreen.swift` and `Life Narattor/Life Narattor/Screens/SearchScreen.swift`.

# Change-029 — Timeline uses CoreData captures

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Data
- Related Skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/daily-narrative-two-layer/SKILL.md
- Related ADRs: None
- Status: Done

## What changed
- Timeline list now loads days from CoreData captures and shows highlights.
- Day detail loads captures for the selected day and groups them by time of day.

## Files touched
- Life Narattor/Life Narattor/Screens/TimelineScreen.swift
- Life Narattor/Life Narattor/Screens/DayDetailScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Timeline reflects real captured data instead of placeholders.
- Day detail shows actual captures grouped by 上午/下午/晚上.

## Verification steps
1) Create several captures across different times of day.
2) Open Timeline → verify day cards show highlights.
3) Tap a day → Day detail shows grouped records.
4) Switch Timeline scope (今天/本周/本月/自定义) → list updates.

## Rollback plan
- Revert `Life Narattor/Life Narattor/Screens/TimelineScreen.swift` and `Life Narattor/Life Narattor/Screens/DayDetailScreen.swift`.

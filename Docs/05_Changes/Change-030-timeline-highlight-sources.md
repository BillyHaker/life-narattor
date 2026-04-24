# Change-030 — Timeline highlight tap + real sources

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / Timeline
- Related Skills:
  - Skills/timeline-browse/SKILL.md
  - Skills/daily-narrative-two-layer/SKILL.md
- Related ADRs: None
- Status: Done

## What changed
- Timeline highlights are tappable and open Capture detail.
- Day detail “引用来源” now lists real capture snippets with timestamps and opens Capture detail.

## Files touched
- Life Narattor/Life Narattor/Models/TimelineModels.swift
- Life Narattor/Life Narattor/Screens/TimelineScreen.swift
- Life Narattor/Life Narattor/Screens/DayDetailScreen.swift

## Contracts/DB changes
- None.

## User-visible impact
- Users can tap day-card highlights to open the related capture.
- Day detail sources show real captures with time stamps.

## Verification steps
1) Create multiple captures in a day.
2) Open Timeline → tap a highlight line → Capture detail opens.
3) Open Day detail → scroll to 引用来源 → tap a line → Capture detail opens.

## Rollback plan
- Revert the files listed above.

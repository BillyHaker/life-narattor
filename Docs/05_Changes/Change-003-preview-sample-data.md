# Change-003 — Record Feed Preview Sample Data

## Meta
- Date: 2026-03-03
- Owner: Codex
- Scope: UI
- Related Skills:
  - Skills/capture-ui/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Preview-only sample captures for Record feed.
- Updated:
  - RecordFeedScreen preview to seed in-memory data.
- Removed:
  - None.

## Files / Modules touched
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- No runtime impact; affects previews only.

## Verification
- Steps:
1) Render preview for RecordFeedScreen.
2) Confirm 3 sample captures show with QuickAck bars.

## Rollback plan
- Remove the preview block and SamplePreviewData section.

# Change-001 — V1 Shell, Capture UI, Persistence Skeleton, AI Mocks

## Meta
- Date: 2026-03-03
- Owner: Codex
- Scope: UI/DB/API/AI
- Related Skills:
  - Skills/ia-navigation/SKILL.md
  - Skills/capture-ui/SKILL.md
  - Skills/ai-interaction/SKILL.md
  - Skills/database-schema/SKILL.md
- Related ADRs: ADR-001
- Status: Done

## What changed
- Added:
  - 4-tab app shell (Record/Timeline/Projects/Review) with lo-fi screens.
  - Record/Capture feed UI with fixed input bar, capture cards, and QuickAck bar.
  - CoreData persistence skeleton with Capture entity.
  - AI mock interfaces for QuickAck and DeepTask.
- Updated:
  - App entry to inject persistence context.
  - ContentView to host TabView and Record screen.
- Removed:
  - Default template UI.

## Files / Modules touched
- Life Narattor/Life Narattor/ContentView.swift
- Life Narattor/Life Narattor/Life_NarattorApp.swift
- Life Narattor/Life Narattor/AI/AIService.swift
- Life Narattor/Life Narattor/Data/PersistenceController.swift
- Life Narattor/Life Narattor/Data/CaptureEntity.swift
- Life Narattor/Life Narattor/Models/CaptureItem.swift
- Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Life Narattor/Views/CaptureCardView.swift
- Life Narattor/Life Narattor/Views/QuickAckBarView.swift
- Life Narattor/Life Narattor/Views/CaptureInputBarView.swift
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift
- Life Narattor/Life Narattor/Screens/TimelineScreen.swift
- Life Narattor/Life Narattor/Screens/ProjectsListScreen.swift
- Life Narattor/Life Narattor/Screens/ReviewHomeScreen.swift

## DB / API changes
- DB migration:
  - New CoreData entity `CaptureEntity` with fields: id, createdAt, rawText, cleanText, ackTitle, ackDetail, dayPart.
- API contract:
  - Mock AI service exposes QuickAck and DeepTask interfaces.

## User-visible impact
- User sees the V1 4-tab shell and can add captures that persist locally.
- Capture cards show clean text and inline QuickAck confirmation.

## Verification
- Steps:
1) Run the app and open the Record tab.
2) Enter text and tap send.
3) Confirm capture appears and QuickAck bar shows a placeholder.
4) Terminate app and relaunch; confirm capture persists.

## Rollback plan
- Revert files listed above to restore the template UI and remove persistence/AI mocks.

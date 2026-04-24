# Change-002 — Fix Build: Observation Model + CoreData Import

## Meta
- Date: 2026-03-03
- Owner: Codex
- Scope: UI/DB
- Related Skills:
  - Skills/capture-ui/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Observation-based view model updates with @Observable.
- Updated:
  - Record feed uses @State + @Bindable for bindings.
  - App entry imports CoreData to access viewContext.
- Removed:
  - ObservableObject/@Published usage (Combine dependency).

## Files / Modules touched
- Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Life Narattor/Screens/RecordFeedScreen.swift
- Life Narattor/Life Narattor/Life_NarattorApp.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- App builds and launches successfully; Record feed bindings remain functional.

## Verification
- Steps:
1) Build the project in Xcode.
2) Launch the app and type in the Record input field.

## Rollback plan
- Revert the three files above to return to ObservableObject + Combine imports.

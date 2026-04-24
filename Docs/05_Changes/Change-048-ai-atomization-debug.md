# Change-048 — AI atomization + tag suggestions + debug tooling

## Meta
- Date: 2026-03-05
- Owner: Codex
- Scope: AI / Atomization / Tags / DevTools / CoreData
- Related Skills: ai-interaction, atomization, tags, devtools-debug-suite, privacy-redaction-standard
- Related ADRs: Docs/03_Decisions/ADR-009-ai-atomization-tag-suggestions.md
- Status: Done

## What changed
- Added AI atomization + tag suggestion calls and a coordinator to apply results with fallback.
- Introduced suggested-tag state via `AtomTagEntity.isSuggested` and UI confirmation on tag pills.
- Added DevTools AI Debug panel with redacted request/response inspection.
- Added atomization verification samples.

## Files touched
- Life Narattor/AI/AIService.swift
- Life Narattor/Data/AtomizationCoordinator.swift
- Life Narattor/Data/AtomTagEntity.swift
- Life Narattor/Data/AtomTagStore.swift
- Life Narattor/Data/PersistenceController.swift
- Life Narattor/Models/AtomItem.swift
- Life Narattor/Models/AtomizationModels.swift
- Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/DevTools/AIDebugStore.swift
- Life Narattor/DevTools/DevToolsAIDebugView.swift
- Life Narattor/DevTools/DevToolsRootView.swift
- Life Narattor/Screens/SearchScreen.swift
- Life Narattor/Screens/ProjectDetailScreen.swift
- Life Narattor/Screens/RecordFeedScreen.swift
- Docs/06_Testing/AI_Atomization_Samples.md

## Contracts/DB changes
- CoreData: AtomTagEntity adds `isSuggested` (bool, default false).

## User-visible impact
- Atoms tab now shows AI-suggested tag pills with “建议”; tapping confirms the tag.
- Atomization uses AI by default and falls back to rule split if AI fails.
- DevTools gains AI Debug panel.

## Verification steps
1. Run app (Cmd+R).
2. Create a new capture with multi-clause text.
3. Open Capture detail → 拆分 tab; verify atoms appear and suggested tag pill shows “建议”.
4. Tap suggested tag; verify it becomes normal tag and persists.
5. Open DevTools → AI Debug; verify atomize / tag_suggest entries appear with request/response.

## Rollback plan
- Revert changes in AIService/AtomizationCoordinator and AtomTagStore.
- Remove `isSuggested` attribute from CoreData model (PersistenceController) and AtomTagEntity.
- Remove DevTools AI Debug view + store.

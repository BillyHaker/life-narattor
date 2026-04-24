# Change-009 — DEBUG DevTools Suite (Flags, Logs, Storage, Diagnostics)

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: UI / DevTools
- Related Skills:
  - Skills/devtools-debug-suite/SKILL.md
- Related ADRs: ADR-003
- Status: Done

## What changed
- Added:
  - DevTools tab (DEBUG only) with App Info, Feature Flags, Logs, Storage, Diagnostics export.
  - FeatureFlags + LogStore infrastructure.
  - Diagnostics export that writes a bundle folder for sharing.
  - CoreData storage counts provider.
- Updated:
  - ContentView to include DevTools tab under DEBUG.
- Removed:
  - None.

## Files / Modules touched
- Life Narattor/Life Narattor/DevTools/FeatureFlags.swift
- Life Narattor/Life Narattor/DevTools/LogStore.swift
- Life Narattor/Life Narattor/DevTools/DebugReadableStorage.swift
- Life Narattor/Life Narattor/DevTools/DiagnosticsExporter.swift
- Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift
- Life Narattor/Life Narattor/DevToolsSupport/CoreDataDebugStorageProvider.swift
- Life Narattor/Life Narattor/ContentView.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- DEBUG builds show a Dev tab for diagnostics; Release builds unchanged.

## Verification
- Steps:
1) Build the project (DEBUG).
2) Run app and confirm Dev tab appears.
3) Open Diagnostics and generate a bundle.

## Rollback plan
- Remove DevTools tab from ContentView and delete DevTools/ + DevToolsSupport files.

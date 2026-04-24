# Change-011 — Diagnostics Latest Folder + Stored Path

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: DevTools
- Related Skills:
  - Skills/devtools-debug-suite/SKILL.md
- Related ADRs: ADR-003
- Status: Done

## What changed
- Added:
  - `Diagnostics/latest` folder updated on each export.
  - Latest diagnostics path stored in UserDefaults and shown in UI.
- Updated:
  - Diagnostics UI to display and copy latest path.
- Removed:
  - None.

## Files / Modules touched
- Life Narattor/Life Narattor/DevTools/DiagnosticsExporter.swift
- Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- Debug diagnostics are always accessible at a stable "latest" path.

## Verification
- Steps:
1) Build DEBUG app.
2) Generate diagnostics bundle twice.
3) Confirm `Documents/Diagnostics/latest` updates and UI shows latest path.

## Rollback plan
- Remove latest folder copy and UserDefaults tracking.

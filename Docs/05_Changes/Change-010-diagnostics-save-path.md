# Change-010 — Save Diagnostics Bundle to Documents/Diagnostics

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
  - Diagnostics export now saves under Documents/Diagnostics with timestamped folder names.
  - Diagnostics UI shows saved path and offers copy button.
- Updated:
  - Diagnostics exporter to create base folder if missing.
- Removed:
  - TemporaryDirectory export path.

## Files / Modules touched
- Life Narattor/Life Narattor/DevTools/DiagnosticsExporter.swift
- Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- DevTools diagnostics bundles persist in a predictable folder and are easier to retrieve.

## Verification
- Steps:
1) Build DEBUG app and open DevTools > Diagnostics.
2) Generate diagnostics bundle and confirm path is shown.
3) Use ShareLink or copy path to retrieve the folder.

## Rollback plan
- Revert DiagnosticsExporter to use temporaryDirectory and remove path UI.

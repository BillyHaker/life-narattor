# ADR-003 — Add Debug-only DevTools Suite

## Meta
- Date: 2026-03-04
- Status: Accepted
- Decision owners: Codex
- Scope: UI / Infra
- Related Skills:
  - Skills/devtools-debug-suite/SKILL.md
- Related files/modules:
  - Life Narattor/Life Narattor/DevTools/**
  - Life Narattor/Life Narattor/ContentView.swift

## Context
- Debugging UI and data issues requires quick access to app info, flags, and local storage.
- The seed pack now recommends a Debug-only DevTools suite.

## Decision
- Implement a DEBUG-only DevTools tab with feature flags, log viewer, storage inspector, and diagnostics export.

## Rationale
- Speeds up iteration and troubleshooting without affecting production builds.
- Centralizes debug toggles and diagnostics in one place.

## Consequences
- Positive:
  - Faster debugging and reproducible diagnostics bundles.
- Negative:
  - Additional code and UI in DEBUG builds.

## Validation
- DevTools tab appears only in DEBUG; Release builds omit it.
- Diagnostics export produces a shareable file.

## Links
- Session log: Docs/04_Sessions/2026-03-04_session-006.md
- Change log: Docs/05_Changes/Change-009-devtools-debug-suite.md

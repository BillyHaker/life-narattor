---
name: project-ideation-guided
description: Meta-skill: guided ideation (diverge/converge) using mature UI patterns; outputs Project Blueprint.
version: 1.0
tags:
  - meta
  - ideation
  - blueprint
---
# Guided Product Ideation (Meta)

## Required outputs
- PROJECT_BLUEPRINT.md
- Decision table (choices + rationale)
- 5+ scenario scripts (happy/low-effort/power/edge)

## Required decisions
- Target user + moment of use
- Core promise (one sentence)
- MVP scope + non-goals
- Primary navigation pattern
- Core workflows (3–5)
- Data objects (high-level)
- AI usage (none/assist/deep) and limits

## Constraint
Ask minimal questions; always provide defaults and A/B/C options with simple pros/cons.

## Process

1. **Diverge:** Using the UI Pattern Library, brainstorm multiple UI patterns and feature approaches for each major function.  Propose at least three options (A/B/C) for each area, providing a brief rationale, pros/cons, and relative complexity (low/medium/high) for a non‑technical product owner.
2. **Converge:** Present the options in a clear menu and help the user select one per function.  Record the choices and their rationales in a decision table within the `PROJECT_BLUEPRINT.md`.
3. **Scenario scripts:** After converging on the main flows, write at least five scenario scripts (e.g., happy path, low‑effort, power user, edge case, failure/recovery) that will be used later for testing and acceptance.

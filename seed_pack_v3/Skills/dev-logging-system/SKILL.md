---
name: dev-logging-system
description: Universal dev logging system: Session/ADR/Change/Handover structure + templates + DoD gates.
version: 1.0
tags:
  - docs
  - logging
  - handoff
  - process
---
# Dev Logging System

## Purpose
Enable multi-AI handoff without losing context. Any contributor can understand what happened in 60 seconds.

## Required artifacts
- Session Log: Docs/04_Sessions/YYYY-MM-DD_session-XXX.md
- ADR: Docs/03_Decisions/ADR-00X-*.md
- ChangeLog: Docs/05_Changes/Change-00X-*.md
- Handover: Docs/99_Handover/YYYY-MM-DD_*.md

## DoD gate
No “done” work without ChangeLog + verification + rollback note (when risky).

## Privacy & redaction
All session logs, ADRs, change logs and diagnostics exports must apply the redaction rules defined in the `privacy-redaction-standard` skill.  At minimum, P0 secrets (tokens, passwords) must never appear in logs; P1 identifiers should be redacted by default; and any user‑generated content (P2) should only be exported with explicit consent.

## Templates expected
- Templates/SESSION_LOG_TEMPLATE.md
- Templates/ADR_TEMPLATE.md
- Templates/CHANGELOG_TEMPLATE.md
- Templates/HANDOVER_TEMPLATE.md
- Templates/PR_TEMPLATE.md

# Change-008 — Integrate seed_pack_v3 Rules/Docs/Templates/Skills

## Meta
- Date: 2026-03-04
- Owner: Codex
- Scope: Docs / Rules / Skills
- Related Skills:
  - Skills/skills-governance/SKILL.md
- Related ADRs: 
- Status: Done

## What changed
- Added:
  - Seed-pack meta skills under `Skills/`.
  - Docs folder structure (01_Product, 02_Architecture, 06_Testing) if missing.
- Updated:
  - Rules and Templates replaced with seed_pack_v3 versions.
  - Docs/00_Index.md replaced with seed_pack_v3 version.
  - Skills/SKILLS_INDEX.md updated to reference seed-pack meta skills.
- Removed:
  - None.

## Files / Modules touched
- Rules/AI_RULES.md
- Rules/DEV_LOG_RULES.md
- Rules/CONTEXT.md
- Rules/PLAN_TEMPLATE.md
- Rules/REVIEW_CHECKLIST.md
- Rules/SECURITY.md
- Rules/TDD_GUIDE.md
- Rules/WORKFLOW.md
- Docs/00_Index.md
- Templates/ADR_TEMPLATE.md
- Templates/CHANGELOG_TEMPLATE.md
- Templates/HANDOVER_TEMPLATE.md
- Templates/PR_TEMPLATE.md
- Templates/SESSION_LOG_TEMPLATE.md
- Skills/SKILLS_INDEX.md
- Skills/<seed-pack meta skills>/**
- Docs/01_Product/
- Docs/02_Architecture/
- Docs/06_Testing/

## DB / API changes
- DB migration:
  - None.
- API contract:
  - None.

## User-visible impact
- No runtime impact; developer workflow docs and skills updated.

## Verification
- Steps:
1) Open Rules/ and Templates/ files to confirm updated content.
2) Confirm Skills/SKILLS_INDEX.md lists new meta skills.

## Rollback plan
- Restore previous Rules/Docs/Templates/Skills index from VCS or backup.

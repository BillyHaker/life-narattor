---
name: templates-scaffolding-generator
description: Meta-skill: generate Docs/ and Templates/ scaffolding (session/ADR/changelog/handover/PR) and required README/CLAUDE pointers.
version: 1.0
tags:
  - meta
  - templates
  - docs
  - scaffolding
---
# Templates & Docs Scaffolding Generator (Meta)

## Purpose
Generate a standard, reusable documentation and template structure for any new app project, so humans and AIs collaborate consistently.

This meta-skill is project-agnostic and should output:
- `Docs/` folder structure + `Docs/00_Index.md`
- `Templates/` folder with standard templates
- `Rules/DEV_LOG_RULES.md` (or equivalent) and references in README/CLAUDE.md

## Outputs (Required)
When invoked, the AI must generate the following files (or provide exact file contents to be created):

### Docs structure
- Docs/00_Index.md
- Docs/01_Product/
- Docs/02_Architecture/
- Docs/03_Decisions/
- Docs/04_Sessions/
- Docs/05_Changes/
- Docs/06_Testing/
- Docs/99_Handover/

### Templates
- Templates/SESSION_LOG_TEMPLATE.md
- Templates/ADR_TEMPLATE.md
- Templates/CHANGELOG_TEMPLATE.md
- Templates/HANDOVER_TEMPLATE.md
- Templates/PR_TEMPLATE.md

### Rules
- Rules/DEV_LOG_RULES.md (or a reference to the existing one)
- README/CLAUDE.md guidance must link to:
  - Rules/AI_RULES.md
  - Rules/DEV_LOG_RULES.md
  - Skills/SKILLS_INDEX.md
  - Docs/00_Index.md

## Quality requirements
- Templates must include: Meta, Goal, Work Log, Decisions, Changes, Verification, Rollback, Next steps.
- Docs/00_Index.md must act as a single starting point and explain the folder map.
- The generated content must not depend on any specific product domain.

## Acceptance
- A newly created repo can adopt the structure by copy/paste.
- New AI/devs can locate rules/specs/logs in <60 seconds.

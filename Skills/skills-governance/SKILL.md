---
name: skills-governance
description: Governance for updating Skills/specs safely (ADR + ChangeLog + versioning).
version: 1.0
tags:
  - governance
  - specs
  - workflow
---
# Skills Governance

## Rule
If implementation behavior changes, the relevant Skill must change. If a Skill changes, it must be traceable (ADR/ChangeLog).

## Required workflow
1) Session Log notes intent to change skills
2) ADR required if UX/DB/API/privacy changes
3) Update SKILL.md with scoped edits + bump version
4) Create/Update ChangeLog with verification + rollback
5) Update SKILLS_INDEX if new skills added

## Versioning & naming conventions

- **Semantic versions:** Use `MAJOR.MINOR.PATCH` for the `version` field in each skill’s front‑matter.  Increment the **major** version when you introduce breaking changes; increment the **minor** version when adding new, backward‑compatible behaviour; increment the **patch** version for clarifications or minor fixes.  Always update the version when modifying a skill.
- **Naming:** Skill folders and names should be all lower‑case and hyphen‑separated.  Avoid spaces or underscores and use descriptive names that reflect the skill’s scope (e.g., `acceptance-testing-min-bar`).

## Acceptance
- Every skill change links to ADR/ChangeLog
- Versions bumped
- Verification steps included

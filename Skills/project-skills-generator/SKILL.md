---
name: project-skills-generator
description: Meta-skill: generate project-specific Skills library + SKILLS_INDEX from PROJECT_BLUEPRINT, including when to split into new skills.
version: 1.0
tags:
  - meta
  - skills
  - generator
---
# Project Skills Generator (Meta)

## Outputs
- Project-specific Skills folders (one per major workflow/module)
- Project SKILLS_INDEX.md
- Coverage report (fix missing until complete)

## When to create a new Skill
Create a dedicated Skill if ANY is true:
- Multi-screen or many states
- Strict contracts (DB/API/AI output)
- Privacy/security implications
- Reused across modules
- Non-trivial edge cases

## Skill completeness DoD
Every generated skill must include:
- UI entry + layout
- Interactions + states
- Data objects
- AI I/O + example JSON (if applicable)
- Edge cases
- Acceptance criteria

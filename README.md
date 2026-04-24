# Rules Skills

A minimal, self-contained rules toolkit for new iOS SwiftUI projects (no spaces in folder name for easier CLI use).

## AI Development Guidance (Required)
1. Always start by reading `Rules/AI_RULES.md`.
2. For any task, locate the matching spec under `Skills/` (begin with `Skills/SKILLS_INDEX.md`) and implement strictly against the skill’s UI + acceptance criteria.
3. If a decision is unclear, re-check `Rules/` and the relevant `Skills/*/SKILL.md` before proceeding.

## Dev Logging (Required)
- Start here: `Docs/00_Index.md` (setup: `Docs/00_Index/DEV_LOGGING_SETUP.md`)

## Files
- CLAUDE_TEMPLATE.md: drop-in project root rule file
- AI_RULES.md: minimal always-on rules
- WORKFLOW.md: standard execution flow
- PLAN_TEMPLATE.md: planning template for complex tasks
- TDD_GUIDE.md: test-first workflow and coverage targets
- REVIEW_CHECKLIST.md: code review checks
- SECURITY.md: security baseline
- CONTEXT.md: context management rules

## How to use
1. Copy `CLAUDE_TEMPLATE.md` to project root as `CLAUDE.md`.
2. Create `Rules/AI_RULES.md` in the project and copy contents from `AI_RULES.md`.
3. Verify `CLAUDE.md` references `Rules/AI_RULES.md`.
4. Keep the rest as references or copy into Docs as needed.

## Xcode note
Xcode Agent reads `CLAUDE.md` automatically. Ensure it references `Rules/AI_RULES.md`.

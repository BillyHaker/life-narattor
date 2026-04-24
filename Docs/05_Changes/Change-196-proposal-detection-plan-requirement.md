---
date: 2026-04-24
owner: Codex
scope: Rules/Skills
related_skills:
  - Skills/acceptance-testing-min-bar/SKILL.md
status: Done
---

# Change-196 — Proposal Detection Plan Requirement

## What Changed
- Upgraded `acceptance-testing-min-bar` to v1.1.
- Added a mandatory `Proposal Detection Plan` requirement for non-trivial change proposals.
- Updated the universal plan template to require a detection plan before implementation.
- Updated the workflow handoff requirements so Codex Execution Briefs include detection plans.
- Updated the skills index so future agents can discover this requirement.

## Files Touched
- `Skills/acceptance-testing-min-bar/SKILL.md`
- `Rules/PLAN_TEMPLATE.md`
- `Rules/WORKFLOW.md`
- `Skills/SKILLS_INDEX.md`
- `Docs/04_Sessions/2026-04-24_session-002.md`
- `Docs/05_Changes/Change-196-proposal-detection-plan-requirement.md`

## User-Visible Impact
Future proposals should explicitly explain how the change will be detected and proven successful, rather than only saying that tests will be run.

## Verification Steps
- `rg -n "Detection Plan|detection plan|Proposal Detection Plan|检测方案" Skills/acceptance-testing-min-bar/SKILL.md Rules/PLAN_TEMPLATE.md Rules/WORKFLOW.md Skills/SKILLS_INDEX.md Docs/04_Sessions/2026-04-24_session-002.md Docs/05_Changes/Change-196-proposal-detection-plan-requirement.md`
- `git diff --check`
- Confirm `git status --short` only includes the expected governance and log files before commit.

## Rollback Notes
- Revert the commit for this change to remove the requirement.
- If the requirement is too strict, keep the skill update and loosen only `Rules/PLAN_TEMPLATE.md` / `Rules/WORKFLOW.md` wording.

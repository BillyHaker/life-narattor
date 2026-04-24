---
name: kickoff-prompt-generator
description: Meta-skill: generate a reusable kickoff prompt that runs ideation -> blueprint -> project skills -> scaffolding -> zip deliverable.
version: 1.0
tags:
  - meta
  - kickoff
  - prompt
  - workflow
---
# Kickoff Prompt Generator (Meta)

## Purpose
Generate a strong, reusable **start command** that ensures an AI agent:
1) Reads the seed pack rules and meta-skills
2) Runs the ideation process (diverge -> converge)
3) Produces a PROJECT_BLUEPRINT
4) Generates project-specific Skills + SKILLS_INDEX using the generator
5) Generates Docs/Templates scaffolding
6) Produces a final zip deliverable

This meta-skill is project-agnostic. It adapts the start command to the chosen platform (iOS/web/etc).

## Inputs
- Project name
- Target platform(s): iOS / Android / Web / Backend
- Desired depth: minimal / normal / thorough

## Output (Required)
A single prompt block the user can paste into Claude Code / Cursor / ChatGPT agent mode.

The prompt must:
- Require reading:
  - seed SKILLS_INDEX.md
  - skills-governance
  - dev-logging-system
- Require generating:
  - PROJECT_BLUEPRINT.md
  - project Skills + SKILLS_INDEX
  - Docs/ + Templates/
- Require a coverage report and re-generation until complete
- Enforce simple A/B/C option explanations for user choices

## Default behavior
- Ask minimal but critical questions
- Provide defaults when user is unsure
- Use clear “gate” checkpoints before moving on

## Acceptance
- The prompt reliably produces the same set of artifacts across different AI tools.
- The user can make decisions without technical knowledge.

# Seed Pack (Universal) — Start Any App Project With AI

This repo folder is a **universal seed pack**: rules + docs + templates + meta-skills that help you:
1) Think through a new product with AI (diverge → converge)
2) Produce a `PROJECT_BLUEPRINT.md`
3) Automatically generate a **project-specific Skills pack** (`project_skills/`) + `SKILLS_INDEX.md`
4) Run development with consistent logs (Session / ADR / Change / Handover)

## Required reading order (for any AI agent)
1. `Rules/AI_RULES.md`
2. `Rules/DEV_LOG_RULES.md`
3. `Skills/SKILLS_INDEX.md`
4. `Docs/00_Index.md`

## How to start a new project (recommended)
- Use the meta-skill: `Skills/kickoff-prompt-generator/SKILL.md`
- Paste the generated kickoff prompt into Claude Code / Cursor / ChatGPT agent mode.

## Contributing

If you wish to extend or improve the seed pack itself, please read `CONTRIBUTING.md` for guidance on naming conventions, versioning, updating the skills index and maintaining project agnosticism.

## Where project-specific specs will live
- The agent must generate a new folder: `project_skills/<project_name>/`
- That folder will contain project skills + a project `SKILLS_INDEX.md`.
- Keep this seed pack **project-agnostic**.

## Packaging hygiene (important)
- Avoid spaces in folder names.
- Do not commit macOS metadata: `.DS_Store`, `__MACOSX/`.

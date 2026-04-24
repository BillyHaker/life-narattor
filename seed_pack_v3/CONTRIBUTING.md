# Contributing to the Seed Pack

We welcome contributions that improve the universality, clarity and robustness of this seed pack.  Please keep the following guidelines in mind when extending or modifying the repository:

## Adding or Updating Skills

- **Naming:** Use lower‑case words separated by hyphens (e.g., `feature-flags-governance`).  Avoid spaces or underscores.
- **Folder structure:** Each skill lives in its own folder under `Skills/` with a single `SKILL.md` file.
- **YAML front‑matter:** Every `SKILL.md` must start with YAML front‑matter containing at least `name`, `description`, `version` and optional `tags`.  This makes the skill machine‑readable.
- **Versioning:** Follow semantic versioning for skills.  Increment the **major** version when you introduce breaking changes or remove functionality; increment the **minor** version when adding new, backward‑compatible behaviour; increment the **patch** version for clarifications or bug fixes.  Update the version in the front‑matter and record the change in an ADR and ChangeLog as defined in `Rules/DEV_LOG_RULES.md`.
- **Updating the index:** When adding a new skill or renaming an existing one, update `Skills/SKILLS_INDEX.md` so that the full alphabetical list remains complete.  If the skill is a meta‑skill (drives generation or workflow), consider adding it to the “Meta‑skills” section as well.
- **Traceability:** Ensure any substantial change to a skill is accompanied by a Session Log entry explaining why, an ADR if the change affects contracts or behaviour, and a ChangeLog entry detailing the modification and how it was verified.

## Creating New Templates or Rules

If you introduce new templates or rules, place them under `Templates/` or `Rules/` respectively.  Update `Docs/00_Index.md` or the appropriate skills to reference the new files so that agents know where to look.

## Maintaining the Seed Pack

This seed pack is intended to remain project‑agnostic.  Do not add any product‑specific content.  Use examples sparingly and only to illustrate universal concepts.  When in doubt, ask whether the addition would apply equally well to any project; if not, move it to a project‑specific skills folder instead.
# Change-095 — Record Modeling Skill and Knowledge Card Integration

## Meta
- Date: 2026-03-09
- Owner: Codex (GPT-5)
- Scope: Docs/Skills/DataModeling
- Related Skills: skill-creator, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- 新增 `record-modeling` Skill，作为记录层核心规范：
  - 三层模型：`source / structured / rendered`
  - 四类记录：`log / action / insight / decision`
  - 通用 `facets` 设计，避免把 schema 锁死在“问题分析型”记录上
  - 当前 `CaptureEntity / ArtifactEntity` 的渐进式迁移建议
- 新增知识卡接入参考：
  - 明确外部学习/读书工具导入时使用 `kind = insight`
  - 提供 canonical payload shape 和推荐渲染顺序
  - 保证知识卡可以接入同一数据库主干，而不是单独分叉
- 更新 `SKILLS_INDEX`，让后续 agent 可正式发现并复用该规范

## Files Changed
- `Skills/record-modeling/SKILL.md`
- `Skills/record-modeling/references/knowledge-card-integration.md`
- `Skills/SKILLS_INDEX.md`
- `Docs/04_Sessions/2026-03-09_session-048.md`
- `Docs/05_Changes/Change-095-record-modeling-skill-and-knowledge-card-integration.md`

## User-visible impact
- None directly. This is a schema and rendering guidance addition for future implementation.

## Verification Steps
1. Confirm `Skills/record-modeling/SKILL.md` has valid frontmatter and clear trigger description.
2. Confirm `Skills/record-modeling/references/knowledge-card-integration.md` is linked from the main skill.
3. Confirm `Skills/SKILLS_INDEX.md` includes `record-modeling`.

## Rollback Notes
- Remove the new `Skills/record-modeling/` folder.
- Revert the `Skills/SKILLS_INDEX.md` entry.

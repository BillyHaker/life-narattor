# Change-096 — Record Schema Decision and Formal Entity Plan

## Meta
- Date: 2026-03-09
- Owner: Codex (GPT-5)
- Scope: DataModeling / ADR / Skills
- Related Skills: record-modeling, dev-logging-system
- Related ADRs: ADR-010-record-schema-and-revision-model.md
- Status: Done

## What changed
- 将 `record-modeling` Skill 升级为 v1.1，正式定义以下实体方向：
  - `CaptureEntity` 仅保留 source layer 责任
  - `RecordEntity` 作为用户可见记录主表
  - `RecordRevisionEntity` 作为版本化语义与渲染缓存容器
  - `RecordTagLinkEntity` 作为 record-level 标签关系
- 新增 ADR-010，正式接受该分层与 revision 模型
- 更新知识卡接入参考，明确外部读书/学习卡应落到：
  - `RecordEntity(kind=insight)`
  - `RecordRevisionEntity.payloadJSON = record_payload_v1`

## Files Changed
- `Skills/record-modeling/SKILL.md`
- `Skills/record-modeling/references/knowledge-card-integration.md`
- `Docs/03_Decisions/ADR-010-record-schema-and-revision-model.md`
- `Docs/04_Sessions/2026-03-09_session-049.md`
- `Docs/05_Changes/Change-096-record-schema-decision-and-formal-entity-plan.md`

## User-visible impact
- None directly. This change defines the canonical persistence direction for future implementation.

## Verification Steps
1. Confirm `Skills/record-modeling/SKILL.md` and `ADR-010` use the same entity names and responsibilities.
2. Confirm knowledge card import guidance points to `RecordEntity + RecordRevisionEntity`.
3. Confirm ADR links to existing session/change files.

## Rollback Notes
- Revert `Skills/record-modeling/SKILL.md` to pre-v1.1 content.
- Remove `Docs/03_Decisions/ADR-010-record-schema-and-revision-model.md`.
- Remove `Docs/04_Sessions/2026-03-09_session-049.md`.
- Remove `Docs/05_Changes/Change-096-record-schema-decision-and-formal-entity-plan.md`.

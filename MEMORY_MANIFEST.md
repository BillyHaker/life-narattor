# MEMORY_MANIFEST
MEMORY_VERSION: 2026-03-08.2

## Must-read on change (re-read only if MEMORY_VERSION changes)
- AGENTS.md
- CLAUDE.md
- Docs/00_Index/EXECUTION_BRIEF.md
- Rules/AI_RULES.md
- Rules/DEV_LOG_RULES.md
- Rules/WORKFLOW.md
- THREADING_FIX_FINAL.md
- COMPLIANCE_FIX_SUMMARY.md
- Skills/SKILLS_INDEX.md
- Skills/self-model/SKILL.md                        ← 2026-03-08 新增：第二自我模块完整规范
- Docs/01_Product/SecondSelf_Design_2026-03-08.md   ← 2026-03-08 新增：设计决策存档

## Optional on change (read only if task touches it)
- Skills/privacy-redaction-standard/SKILL.md
- Skills/database-schema/SKILL.md
- Skills/ai-interaction/SKILL.md   ← v0.2 已更新：分层流水线 + ModelProvider
- Skills/tags/SKILL.md             ← v0.2 已更新：置信度 + 六维框架 + 领域树
- MANUAL_TEST_CHECKLIST.md

## Notes
- If MEMORY_VERSION is unchanged, do not re-read long docs.
- If you must load details, open only the specific file(s) needed.
- 2026-03-08.1 变更摘要：第二自我模块设计完成（self-model v1.1），标签质量控制规范补齐（tags v0.2），AI 调用层新增 ModelProvider 抽象（ai-interaction v0.2）。
- 2026-03-08.2 变更摘要：AI_RULES.md v1.2 新增 Rule 9（三层诊断机制），要求非预期行为必须先诊断根本原因再提出修复方案。

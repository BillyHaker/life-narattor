# Life Narrator Skills Library (V1)

本文件夹包含模块化 Agent Skills。每个子文件夹对应一个 Skill，内含 `SKILL.md`。

---

## ⚡ 当前迭代（Codex 先读这里）

当前执行包：

```
Docs/00_Index/EXECUTION_BRIEF.md
```

**2026-03-08 规范更新摘要**（设计已完成，等待实现）：
- `self-model`（新增 v1.1）：第二自我模块完整规范，含四层数据结构、四种 Job、Proposal 审批、Prompt 构建契约
- `tags`（更新 v0.2）：隐性标签置信度、主辅区分、六维框架、领域分类树
- `ai-interaction`（更新 v0.2）：分层 Atomization 流水线、ModelProvider 抽象层

**上一迭代任务**（iter-001，若未完成仍需执行）：
1. 实现"查看来源"UI（Source Highlight）—— 参考 `atomization` + `capture-ui` skill
2. 添加核心合规逻辑单元测试 —— 参考 `acceptance-testing-min-bar` + `privacy-redaction-standard` skill

> 每轮迭代开始前，规范负责人会更新 `Docs/00_Index/EXECUTION_BRIEF.md`。Codex 应以最新 Brief 为准，不得依赖本节内容推断当前任务。

---

## 必读顺序（全量上下文）
1. `product-northstar`
2. `skills-governance` — How specs (Skills) may be updated safely (ADR + ChangeLog + versioning)
3. `ia-navigation`
4. `capture-ui`
5. `ai-interaction`
6. `database-schema`
7. `clean-defiller`
8. `atomization`
9. `tags`
10. `daily-narrative-two-layer`
11. `user-scenarios`

## Feature add-ons (read when implementing)
- `assist-archive-card` — Assist mode (<=3 turns) that outputs **Reply + Archive Card** and saves as a durable asset
- `self-model` — 第二自我模块：四层自我模型（锚点/主体/当期补丁/忽略条目）、季度整合 Job、Proposal 审批、两种对话模式（主题回顾 / 第二自我模拟）⭐ 2026-03-08 新增
- `project-review` — Deep review tasks for project narratives (longer running)
- `review-memory` — Second-brain review surfaces (weekly/monthly/theme/project)
- `record-modeling` — 通用记录模型：source/structured/rendered 三层、record kinds、facets、知识卡片接入
- `timeline-browse` — Timeline browsing patterns and day entry points
- `speech-transcription` — Voice capture + transcription pipeline and failure states
- `search` — Keyword/tag search (vector search optional placeholder)

## Engineering tooling (universal)
- `devtools-debug-suite` — Debug-only DevTools UI + Feature Flags + Diagnostics Export (minimal production impact)

## Seed governance & quality (universal reference)
- `seed-northstar`
- `dev-logging-system`
- `acceptance-testing-min-bar` — v1.1 requires every non-trivial proposal to include a concrete detection plan before implementation
- `contract-versioning`
- `privacy-redaction-standard`
- `feature-flags-governance`
- `accessibility-guidelines`
- `error-handling-standard`
- `ci-and-quality-assurance`
- `data-governance-and-compliance`
- `internationalization-guidelines`
- `progress-gates-and-checkpoints`
- `project-ideation-guided`
- `project-skills-generator`
- `templates-scaffolding-generator`
- `kickoff-prompt-generator`
- `ui-pattern-library`

## Full list (alphabetical)
- acceptance-testing-min-bar
- accessibility-guidelines
- ai-interaction
- assist-archive-card
- atomization
- capture-ui
- ci-and-quality-assurance
- clean-defiller
- contract-versioning
- daily-narrative-two-layer
- data-governance-and-compliance
- database-schema
- dev-logging-system
- devtools-debug-suite
- error-handling-standard
- feature-flags-governance
- ia-navigation
- internationalization-guidelines
- kickoff-prompt-generator
- privacy-redaction-standard
- product-northstar
- progress-gates-and-checkpoints
- project-ideation-guided
- project-review
- project-skills-generator
- record-modeling
- review-memory
- search
- seed-northstar
- self-model
- skills-governance
- speech-transcription
- tags
- templates-scaffolding-generator
- timeline-browse
- ui-pattern-library
- user-scenarios

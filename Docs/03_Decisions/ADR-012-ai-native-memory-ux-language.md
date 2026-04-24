---
date: 2026-04-24
owner: Codex
scope: UX/UI
status: Accepted
related_skills:
  - Skills/product-northstar/SKILL.md
  - Skills/capture-ui/SKILL.md
  - Skills/timeline-browse/SKILL.md
  - Skills/review-memory/SKILL.md
  - Skills/project-review/SKILL.md
---

# ADR-012 — AI-Native Memory UX Language

## Context
The current UI was clean but still felt like a traditional record/search/project-management app with AI entry points. The product north star says Life Narrator should be record-first, low-pressure, traceable, and should feel like a calm self-mirror rather than a chatbot, task manager, or formal report generator.

## Alternatives
- Keep current labels and only polish spacing. Low risk, but does not address the product-shape problem.
- Make AI the primary navigation layer. Distinctive, but too risky for V1 and likely to become chatbot-like.
- Keep current architecture while shifting language and hierarchy toward lightweight memory: record, organize, review, line/signal.

## Decision
Adopt the third option for this pass. Keep data models and navigation structure intact, but change visible language and first-screen hierarchy toward an AI-native memory container:
- record-first wording: `记一句`, `已接住`
- review wording: `回看`, `事实与联系`, `线索`
- timeline wording: `整理成今日叙事`
- project surface wording: `线索`

## Rationale
This preserves app stability before beta while moving the product closer to the desired mental model. It avoids turning AI into a separate chatbot and instead frames AI as a quiet organizing layer behind records, timeline, review, and long-running lines.

## Consequences
- Bottom tab `项目` becomes `线索`, while underlying project/tag data remains unchanged.
- Some technical concepts remain internally named `Project` or `Tag`; this pass changes only user-facing wording.
- Future work can deepen the model by connecting hidden tags/system signals to the Lines surface.

## Validation
- Xcode simulator build must pass.
- Unit/UI tests must pass.
- Text scan should not find old high-pressure first-screen terms such as `生成当天叙事`, `标签组`, `暂无关联记录`, or `记录成功` in primary screens.
- Manual screenshot inspection should show the Record screen using low-pressure wording and the bottom tab label `线索`.

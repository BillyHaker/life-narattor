# Docs Index（Life Narrator）

本文件夹记录开发历史，支持多 AI 交接。

---

## ⚡ Codex / AI 代理：先读这里

**第一步**：读取 Manifest 确认版本，然后读取 Brief：

```
MEMORY_MANIFEST.md          ← 先读这里，确认 MEMORY_VERSION
Docs/00_Index/EXECUTION_BRIEF.md   ← 当前规范交接文件（始终以此为准）
```

> 若 MEMORY_VERSION 与上次加载不同，按 Manifest 的 Must-read 列表重读指定文件。

> 规则：**不得跳过 Brief 直接动代码**。Brief 定义了本次迭代目标、冻结区、DoD 和文档要求。

---

## 完整阅读路径（参考文档顺序）

- 规则：`Rules/AI_RULES.md`、`Rules/DEV_LOG_RULES.md`、`Rules/CONTEXT.md`
- 规范：`Skills/SKILLS_INDEX.md`
- 模板：`Templates/`
- 日志：
  - Sessions：`Docs/04_Sessions/`
  - ADRs：`Docs/03_Decisions/`
  - Changes：`Docs/05_Changes/`
  - Handover：`Docs/99_Handover/`

## 文件夹说明

- `01_Product/` — 产品说明（可选）
- `02_Architecture/` — 架构与契约
- `03_Decisions/` — ADR 决策记录
- `04_Sessions/` — Session 日志
- `05_Changes/` — Change 日志
- `06_Testing/` — 测试备注
- `99_Handover/` — AI 交接文档
- `CODEX_EXECUTION_BRIEF_*.md` — Codex 执行包（每次迭代一份）

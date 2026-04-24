# 交付包 — Life Narrator 验证系统更新

## 操作方法
把 `Rules/`、`Skills/`、`Templates/` 三个文件夹直接拖入 Life Narrator 项目根目录，合并即可。

## 文件结构
```
_delivery/
├── Rules/
│   └── VERIFICATION.md          → Life Narrator/Rules/VERIFICATION.md
├── Skills/
│   └── verification-consolidation/
│       └── SKILL.md             → Life Narrator/Skills/verification-consolidation/SKILL.md
└── Templates/
    └── VERIFICATION_BACKLOG_TEMPLATE.md → Life Narrator/Templates/VERIFICATION_BACKLOG_TEMPLATE.md
```

## 复制完成后，把以下提示词发给 AI

---

我刚向项目里新增了以下文件，请完成初始化：

新增文件：
- Rules/VERIFICATION.md — 延迟批量验证规则
- Skills/verification-consolidation/SKILL.md — 里程碑验证整合工作流
- Templates/VERIFICATION_BACKLOG_TEMPLATE.md — 验证积压清单模板

请执行以下操作：
1. 读取 Rules/VERIFICATION.md，理解新的验证规则
2. 在 Docs/ 目录下，用 Templates/VERIFICATION_BACKLOG_TEMPLATE.md
   创建 Docs/VERIFICATION_BACKLOG.md，项目名填 Life Narrator
3. 读取 Skills/verification-consolidation/SKILL.md，确认你知道
   如何在里程碑节点触发它
4. 确认 AGENTS.md 的 Non-negotiables 区块已包含验证规则摘要，
   如果没有，按 Rules/VERIFICATION.md 的核心条目补入

完成后告诉我：
- VERIFICATION_BACKLOG.md 已创建的路径
- 你理解的触发整合流程的条件是什么

# EXECUTION_BRIEF — Claude → Codex Handoff
Last updated: 2026-03-08
MEMORY_VERSION target: 2026-03-08.2

> 详细版执行包见：`Docs/CODEX_EXECUTION_BRIEF_2026-03-06_iter-001.md`（iter-001 任务若未完成仍需执行）
> 本文件为 Manifest 索引的精简交接摘要，以本文件为准。

---

## ⚡ 2026-03-08 规范更新通知（Codex 必读）

本次更新为**纯规范更新**，无代码变更。以下文件已更新，Codex 实现相关功能时须以新版规范为准：

| 文件 | 版本 | 变更摘要 |
|-----|-----|---------|
| `Skills/self-model/SKILL.md` | v1.1（新建）| 第二自我模块完整规范：四层数据结构、四种 Job（BehavioralUpdate/IdentityUpdate/ContradictionDetector/Consolidation）、Proposal 审批、两种对话模式 |
| `Skills/tags/SKILL.md` | v0.2 | 隐性标签置信度分数、主辅标签区分、六维语义框架、领域分类树（tag-taxonomy.json）|
| `Skills/ai-interaction/SKILL.md` | v0.2 | 分层 Atomization 流水线（Step1 轻量 + Step2 重模型）、ModelProvider 抽象层协议、经济模式数据区域警告 |
| `Docs/01_Product/SecondSelf_Design_2026-03-08.md` | v1.1（新建）| 设计决策存档，含架构决策理由和实现阶段规划 |
| `Rules/AI_RULES.md` | v1.2 | 新增 Rule 9：遇到非预期行为必须先做三层诊断（实现→规范→产品方向），写诊断报告后才可提交修复方案 |

---

## 1) Goal

实现 Atoms 拆分视图的"来源高亮"UI，并为上个 session 修复的核心合规逻辑补充单元测试，完成可追溯性闭环。

---

## 2) Scope

### Must do
- [ ] **Goal 1**：`CaptureDetailSheet` 拆分 tab 中，对有效偏移的 Atom 显示"来源"按钮，点击后在 Clean 文本中高亮对应片段（`AttributedString`，bounds check 防越界）
- [ ] **Goal 1**：无偏移老 Atom 静默隐藏按钮，不报错，不崩溃
- [ ] **Goal 2**：新建 `AIDebugRedactorTests.swift`，覆盖 5 个脱敏 case（sk- 前缀、Bearer token、api_key JSON、email、长内容截断）
- [ ] **Goal 2**：新建 `AtomTagStoreTests.swift`，覆盖 `markAsKey` 持久化和 `deleteAtom` 级联删除
- [ ] 创建 Session Log `Docs/04_Sessions/2026-03-07_session-001.md`（或 -002，取决于当天序号）
- [ ] 创建 Change Log `Docs/05_Changes/Change-049-source-highlight-ui.md`
- [ ] 创建 Change Log `Docs/05_Changes/Change-050-unit-tests-compliance.md`

### Must NOT do
- [ ] 不得修改 `PersistenceController.swift`（CoreData schema 已稳定）
- [ ] 不得修改 `AtomizationCoordinator.swift`（线程模型刚完成修复，见 `THREADING_FIX_FINAL.md`）
- [ ] 不得修改 `AIService.swift`
- [ ] 不得修改 `*.xcodeproj` / `.xcworkspace`
- [ ] 不得修改 `Rules/`、`Skills/`、`Docs/`（由规范负责人维护）
- [ ] 不得在测试文件中写入真实 API Key

---

## 3) Definition of Done (DoD)

- [ ] 构建成功（`Cmd+B`，0 errors）
- [ ] 单元测试全部通过（`Cmd+U`，AIDebugRedactorTests + AtomTagStoreTests 全绿）
- [ ] 手动验证路径完成（见第 6 节）
- [ ] 日志中无隐私泄露（脱敏规则已遵守，`Skills/privacy-redaction-standard` v1.1）
- [ ] 无主线程阻塞回归（`AtomTagStore` 操作均在 `MainActor`）
- [ ] Session Log + Change Log × 2 已按 `Rules/DEV_LOG_RULES.md` 创建
- [ ] `atomization/SKILL.md` Acceptance criteria 第 6 条（来源可追溯）已通过

---

## 4) Relevant Skills / Rules to follow

- `Rules/AI_RULES.md` — 通用规则，重点看 Rule 7（先读 Brief）、Rule 8（冻结区）
- `Rules/DEV_LOG_RULES.md` — 日志规范
- `Skills/atomization/SKILL.md` — 来源按钮规范（Components 节 + Acceptance criteria 第 6 条）
- `Skills/capture-ui/SKILL.md` — Atom list row 结构
- `Skills/privacy-redaction-standard/SKILL.md` v1.1 — 脱敏 5 模式 + 测试用例表
- `Skills/acceptance-testing-min-bar/SKILL.md` — 测试最低覆盖标准

---

## 5) Files allowed to change

**代码**（仅限以下，不得超出）：
```
Life Narattor/Views/CaptureDetailSheet.swift       # 来源按钮 + 高亮 sheet
Life Narattor/Views/AtomDetailSheet.swift          # 可选：Traceability section
Life NarattorTests/AIDebugRedactorTests.swift      # 新建
Life NarattorTests/AtomTagStoreTests.swift         # 新建
```

**文档**（必须创建）：
```
Docs/04_Sessions/2026-03-07_session-00X.md
Docs/05_Changes/Change-049-source-highlight-ui.md
Docs/05_Changes/Change-050-unit-tests-compliance.md
```

---

## 6) Verification steps (Xcode)

### Goal 1 — 来源高亮 UI

1. `Cmd+Shift+K`（Clean Build Folder）→ `Cmd+R`（Run）
2. 创建 Capture："我今天开完会很烦，明天要整理一下思路"
3. 等待 atomization 完成（UI 显示"已拆成 X 条 ▾"）
4. 点击 Capture Card → 切换到"拆分"tab
5. **预期**：有 `start_char/end_char` 的 Atom 尾部显示"来源"链接
6. 点击"来源" → **预期**：弹出 Clean 文本，对应片段以高亮色标记
7. 对老 Atom（无偏移）→ **预期**：不显示"来源"，无报错
8. 快速反复开关高亮 sheet → **预期**：无崩溃，无内存泄漏警告

### Goal 2 — 单元测试

1. `Cmd+U`（Test）
2. **预期**：`AIDebugRedactorTests`（5 个 case）全绿
3. **预期**：`AtomTagStoreTests`（2 个 case）全绿

### 顺带验证（隐私）

1. DevTools → AI Debug 标签 → 触发一次 atomization
2. **预期**：请求体中 API key 显示为 `sk-***REDACTED***`，无原始令牌

---

## 7) Rollback plan

- **Goal 1 回滚**：仅涉及 `CaptureDetailSheet.swift`（和可选的 `AtomDetailSheet.swift`），`git revert` 对应 commit 即可；无 CoreData schema 变更，无数据风险。
- **Goal 2 回滚**：测试文件为新增，直接删除 `AIDebugRedactorTests.swift` 和 `AtomTagStoreTests.swift`，不影响产品代码。
- **如构建失败**：检查 `AttributedString` 索引是否使用 `String.Index`（非 Int 直接下标），以及 `AtomTagStore` 操作是否在 `MainActor` 上下文中。

---

## 8) 关键约束（勿忘）

| 约束 | 说明 |
|------|------|
| `start_char` / `end_char` 类型 | `Int16`，最大 32767；读取时转为 `Int` 再做 bounds check |
| CoreData 线程 | `AtomTagStore` 所有写操作须在主线程 |
| 测试不得含真实 API Key | 用 `"sk-test1234567890abcdef"` 等假值 |
| 语音转写本次不涉及 | `speech-transcription` 实现为下一迭代任务 |

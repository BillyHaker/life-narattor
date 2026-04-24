# VERIFICATION — 延迟批量验证规则
version: 1.0

## 核心原则
**不打断用户**。每次功能开发完成后，Codex 不得立即要求用户手动验证。
所有待验证项写入积压清单，在里程碑节点统一处理。

---

## Rule 1：开发完成后的标准动作

每完成一个功能/修复，Codex 必须：

1. 自行执行可自动化的验证（构建、单元测试、Lint）
2. 将其余待验证项追加到 `Docs/VERIFICATION_BACKLOG.md`
3. **不得**在此打断用户，直接继续下一个任务

自动验证失败时为例外——此时必须立即告知用户，不得压入积压清单。

---

## Rule 2：验证类型分级

| 类型 | 说明 | 执行者 |
|---|---|---|
| `automated` | 构建成功、单元测试通过、Lint 无错 | Codex 自动执行 |
| `simulator` | 界面截图、导航流程截图 | Codex 用 `xcrun simctl` 执行 |
| `ui-test` | 可用 XCUITest 脚本验证的交互 | Codex 编写并执行 |
| `human-visual` | 视觉设计感受、动画流畅度 | 用户判断 |
| `human-logic` | 业务逻辑正确性、边界情况判断 | 用户判断 |

**原则**：能自动化的不交给用户；必须人判断的才上报。

---

## Rule 3：里程碑触发

以下节点触发验证整合流程（运行 `Skills/verification-consolidation/SKILL.md`）：
- 一个功能模块全部开发完成时
- 准备给用户演示之前
- 冲刺/阶段结束时
- 用户主动要求 `请整理一下待验证项` 时

---

## Rule 4：积压清单维护规则

- 每条记录必须包含：ID、关联功能、描述、类型、添加日期、状态
- 状态只有五种：`pending` / `auto-verified` / `superseded` / `consolidated` / `done`
- `superseded`：被后续更改覆盖，不再需要验证，需注明被哪条取代
- `consolidated`：已合并入某次批量验证，需注明合并到哪个验证会话
- Codex 有权将状态从 `pending` 改为 `auto-verified`（自动验证通过）
- 只有用户确认后才能将状态改为 `done`

---

## Rule 5：禁止行为

- ❌ 开发完成后立即输出「请你测试一下 X 功能」
- ❌ 自动验证失败但压入积压清单而不报告
- ❌ 积压清单超过 15 条未触发整合
- ❌ 将 `human-logic` 类验证伪装成可自动化

---
name: ai-rules
description: Universal rules for AI-assisted development. Keep changes minimal, verifiable, and traceable.
version: 1.2
changelog:
  - "v1.0: initial"
  - "v1.1 (2026-03-06): added Rule 7 (read Execution Brief first) and Rule 8 (respect frozen zones)"
  - "v1.2 (2026-03-08): added Rule 9 (three-layer diagnostic before adding constraints)"
---

# AI_RULES（通用，必读）

## 1）规范优先工作流
- 规范存放在 `Skills/`。
- 已实现的行为必须在对应 Skill 中有描述（或在生成的项目 Skill 中）。
- 若 Skill 与代码冲突，以 Skill 为准，并记录 ADR 说明差异。

## 2）改动最小化、可回滚
- 优先小步增量。
- 高风险改动必须附回滚方案。

## 3）始终验证
- UI 改动：提供手动验证步骤（模拟器/设备）。
- 数据/契约改动：提供 fixture 或示例。

## 4）禁止静默重构
- 如需重构，必须说明原因和改动范围，并写 Change Log。

## 5）遵守隐私与安全规范
- 不得在日志/导出中暴露密钥或令牌。
- 严格遵守 `Skills/privacy-redaction-standard`。

## 6）使用项目日志流程
- 按 `Rules/DEV_LOG_RULES.md` 维护 Session Log / ADR / Change Log / Handover。

## 7）执行前必须读 Execution Brief
- 接受任务后，**第一个动作**是找到并阅读最新的 Codex Execution Brief：
  ```
  Docs/CODEX_EXECUTION_BRIEF_<最新日期>_iter-<NNN>.md
  ```
- Brief 定义了本次迭代目标、DoD、冻结区和文档要求。
- 未找到 Brief，或 Brief 与源码状态不符时，停止执行并向人类负责人反馈，不得自行推断目标。

## 8）尊重冻结区（Frozen Zones）
- 每次 Execution Brief 均会列出"绝对不动"的文件/模块（通常是近期刚稳定化的区域）。
- 冻结区内的文件，即便看起来有改进空间，本次迭代也不得修改。
- 若认为冻结区有问题，在 Session Log 中记录，交由规范负责人决策，不得自行解冻。

## 9）遇到非预期行为时先诊断，不要直接加限制

当某个功能表现不达预期时，第一反应不应该是「加一条规则来堵住这个行为」。堆砌限制只能处理已知的具体情况，无法解决根本原因，还会让系统越来越脆弱。

**正确的诊断顺序是从底层往上找问题根源：**

### 第一层：实现层（代码）
阅读相关功能的当前代码实现，回答以下问题：
- 这个功能实际上是怎么工作的？
- 它与对应 Skill 中描述的契约一致吗？
- 是否存在边界条件未处理、状态管理不当、线程问题等实现缺陷？

**→ 若问题在这里**：修复实现，使其符合 Skill 契约，记录 Change Log。

### 第二层：规范层（Skill）
将当前实现与 `Skills/` 中对应 Skill 的设计意图对比，回答以下问题：
- Skill 的设计假设在现实中成立吗？
- Skill 是否遗漏了关键边界条件？
- Skill 的方向本身是否错了——是在解决正确的问题吗？

**→ 若问题在这里**：向规范负责人（Claude）提交 Skill 修改建议，写 ADR 记录为何要改，不得自行修改 Skill。

### 第三层：产品方向层
如果实现正确、规范也合理，但结果仍然不对，问题可能出在产品对用户需求的理解上：
- 我们构建的功能是用户真正需要的吗？
- 设计的使用场景在实际中会这样发生吗？

**→ 若问题在这里**：升级给产品负责人决策，不在代码层面修补。

### 诊断报告格式

每次遇到重复出现的非预期行为，必须在 Session Log 中写一段诊断记录，再提出修复方案：

```
## 非预期行为诊断

**现象**：[描述观察到的具体行为]
**复现步骤**：[如何稳定复现]

**第一层检查（实现）**：[检查了哪些文件，发现什么]
**第二层检查（规范）**：[对应 Skill 的设计意图是什么，是否一致]
**第三层检查（产品）**：[功能方向是否正确]

**根本原因判断**：[哪一层出了问题，为什么]
**建议修复方案**：[针对根本原因的方案，而非补丁]
```

只有完成诊断、确认根本原因之后，才可以提交修复 PR。

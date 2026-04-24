# Verification Backlog
project: [项目名称]
last-updated: YYYY-MM-DD
next-milestone: [里程碑名称，如「v0.2 登录模块完成」]
pending-count: 0

---

## 使用说明（AI 阅读）
- 开发完每个功能后，将新验证项追加到「Pending」区
- 自动验证通过后，直接将状态改为 `auto-verified`，无需通知用户
- 里程碑到达时，运行 `Skills/verification-consolidation/SKILL.md`
- 禁止因积压清单中的项目打断用户工作

---

## Pending（待处理）

<!-- 模板：复制以下格式追加 -->
<!--
### VRF-XXX
- feature: 关联功能名称
- description: 具体需要验证什么
- type: automated | simulator | ui-test | human-visual | human-logic
- added: YYYY-MM-DD
- status: pending
- notes: （可选补充）
-->

---

## Auto-Verified（AI 已自动验证通过）

<!-- Codex 自动执行后移入此区，附验证结果摘要 -->

---

## Superseded（被后续需求覆盖，已作废）

<!-- 格式：
### VRF-XXX ~~[原描述]~~
- superseded-by: VRF-YYY（说明原因）
- date: YYYY-MM-DD
-->

---

## Consolidated（已合并入批量验证会话）

<!-- 格式：
### VRF-XXX
- consolidated-into: 验证会话 [会话编号/日期]
- date: YYYY-MM-DD
-->

---

## Done（用户已确认完成）

<!-- 格式：
### VRF-XXX — [描述]
- verified-by: human | automated
- date: YYYY-MM-DD
- result: pass | fail | partial
- notes: （可选）
-->

# AI Atomization & Tagging Samples (V1)

## Meta
- Date: 2026-03-05
- Owner: Codex
- Scope: AI / Atomization / Tags
- Status: Draft

## Purpose
Provide a small, repeatable set of inputs to validate atomization and tag suggestion quality.

## Samples

### Sample 1 — mixed event + feeling + action
Input:
- 今天开完会有点烦，晚上准备把方案再梳理一遍。

Expected atoms (2–3):
- event: 开完会
- feeling: 有点烦
- action: 晚上准备把方案再梳理一遍

Suggested visible tag (max 1):
- project: 方案

Hidden tags (optional):
- theme: 会议

---

### Sample 2 — short event
Input:
- 吃了个简餐。

Expected atoms (1):
- event: 吃了个简餐

Suggested visible tag:
- (none)

---

### Sample 3 — decision + next step
Input:
- 决定这周把健身计划改成三天。

Expected atoms (2):
- decision: 决定把健身计划改成三天
- action: 这周执行三天

Suggested visible tag:
- goal: 健身计划

---

### Sample 4 — thought + context
Input:
- 总觉得最近节奏有点乱，可能是项目太多。

Expected atoms (2):
- thought: 总觉得最近节奏有点乱
- context: 可能是项目太多

Suggested visible tag:
- theme: 节奏

---

### Sample 5 — question
Input:
- 我是不是应该先把重要的事情列出来？

Expected atoms (1–2):
- question: 是否应该先列出重要事项

Suggested visible tag:
- (none)


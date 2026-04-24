---
skill: verification-consolidation
version: 1.0
status: approved
trigger: 里程碑到达时，或用户说「整理待验证项」
---

# Skill: verification-consolidation — 里程碑验证整合

## 目标
把积压的待验证项进行去重、整合、分级，让 AI 自己验证能验证的，把真正需要用户判断的内容整理成最少的几轮验证会话交给用户。

---

## Step 1：读取积压清单

读取 `Docs/VERIFICATION_BACKLOG.md`，统计：
- `pending` 条目数量
- 涉及的功能模块列表
- 各类型分布（automated / simulator / ui-test / human-visual / human-logic）

输出摘要：
```
📋 积压清单摘要
  待处理：N 条
  功能模块：登录、Dashboard、设置...
  可自动验证：X 条
  需人工判断：Y 条
```

---

## Step 2：标记被覆盖的条目（Superseded）

逐条检查：若某条验证项描述的功能/界面已被后续开发完全替代或删除，将其状态改为 `superseded`，注明原因。

判断标准：
- 该功能模块已被重写 → superseded
- 该界面已在后续迭代中完全重做 → superseded
- 验证内容被更全面的后续条目覆盖 → superseded，注明被哪条覆盖

---

## Step 3：合并可整合的条目

将以下情况的条目合并为一次验证：
- 同一屏幕的多个视觉验证 → 合并为「[屏幕名] 整体视觉验证」
- 同一用户流程的多个步骤 → 合并为「[流程名] 端到端验证」
- 同一功能的正常路径 + 错误路径 → 合并为「[功能名] 完整场景验证」

输出合并计划，等待用户确认（**此步骤需要用户 OK**）：
```
拟合并：
  VRF-003 + VRF-004 + VRF-007 → 「登录流程完整验证」
  VRF-009 + VRF-011 → 「Dashboard 数据展示验证」
是否确认以上合并？
```

---

## Step 4：AI 自动执行可验证项

用户确认后，按以下顺序执行：

### 4a — automated 类
```bash
# 构建检查
xcodebuild -scheme [项目名] -destination 'platform=iOS Simulator,name=iPhone 16' build

# 单元测试
xcodebuild test -scheme [项目名] -destination 'platform=iOS Simulator,name=iPhone 16'
```
记录结果：pass / fail / 具体错误。

### 4b — simulator 类
```bash
# 启动模拟器并截图
xcrun simctl boot "iPhone 16"
# 导航到目标页面后截图
xcrun simctl io booted screenshot ~/Desktop/verification-[VRF-ID]-[描述].png
```
将截图路径记录在积压清单对应条目的 notes 中。

### 4c — ui-test 类
运行对应 XCUITest target，记录通过/失败详情。

将以上条目状态更新为 `auto-verified`，附验证时间和结果摘要。

---

## Step 5：整理人工验证清单

将剩余 `human-visual` 和 `human-logic` 条目整理为验证会话，原则：
- 同一屏幕的视觉验证放在同一会话
- 同一业务流程的逻辑验证放在同一会话
- 每个会话预计耗时 < 10 分钟

输出格式：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧑 需要你验证的内容（共 N 轮，预计 X 分钟）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【第 1 轮】登录流程视觉 + 逻辑（约 3 分钟）
  操作：打开 App → 尝试登录
  验证点：
  □ VRF-003：登录按钮样式是否符合设计稿
  □ VRF-005：错误提示文案是否清晰易懂
  □ VRF-008：登录成功后跳转是否流畅自然
  截图参考：~/Desktop/verification-VRF-003-login.png

【第 2 轮】Dashboard 数据展示（约 5 分钟）
  操作：登录后查看 Dashboard
  验证点：
  □ VRF-009：数据格式是否符合预期（金额、日期）
  □ VRF-011：空数据状态下的提示是否合适

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
完成验证后，告诉我每条的结果（pass / fail / 需修改）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 6：处理验证结果

用户反馈验证结果后：
- `pass` → 更新条目状态为 `done`
- `fail` → 立即创建修复任务，修复后重新加入积压清单（新 VRF-ID）
- `需修改` → 与用户确认修改范围，记录为新任务

---

## Step 7：更新积压清单

将本次整合结果写回 `Docs/VERIFICATION_BACKLOG.md`：
- 更新 `last-updated` 和 `pending-count`
- 所有处理过的条目状态已更新
- 在 `consolidated` 区记录本次会话编号和日期

---

## 反模式提醒
- ❌ 把「需要人判断视觉」的项目标为 `simulator` 类型混过去
- ❌ 合并了逻辑完全无关的两条验证（节省时间但让用户困惑）
- ❌ 积压超过 20 条才触发整合（积压过多导致上下文丢失）
- ❌ 截图工具失败时静默跳过，应报告无法截图

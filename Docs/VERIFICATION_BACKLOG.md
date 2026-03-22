# Verification Backlog
project: Life Narrator
last-updated: 2026-03-22
next-milestone: TBD
pending-count: 16

---

## 使用说明（AI 阅读）
- 开发完每个功能后，将新验证项追加到「Pending」区
- 自动验证通过后，直接将状态改为 `auto-verified`，无需通知用户
- 里程碑到达时，运行 `Skills/verification-consolidation/SKILL.md`
- 禁止因积压清单中的项目打断用户工作

---

## Pending（待处理）

### VRF-001
- feature: DayDetail 本地叙事片段可读性优化
- description: 手测中英混合/长文本时，叙事片段不应在英文单词中间硬截断，且不出现纯标点或空白片段
- type: human-logic
- added: 2026-03-08
- status: pending
- notes: 建议验证路径为 Timeline -> DayDetail -> 今日叙事与引用来源文案一致性

### VRF-002
- feature: DayDetail 叙事与引用来源文案一致性
- description: 同一条来源在“今日叙事”和“引用来源”中应使用同一规范化句子（句尾统一、无额外标点漂移）
- type: human-visual
- added: 2026-03-08
- status: pending
- notes: 展开“引用来源”逐条比对叙事句，反复进入详情页后列表顺序与内容应稳定

### VRF-003
- feature: 录音时长预警与实时电平反馈
- description: 录音接近 5 分钟时应出现 10 秒预警，录音中电平条应随声音变化，进入后台/系统中断时提示原因明确
- type: human-logic
- added: 2026-03-08
- status: pending
- notes: 用户首次验证失败（未见记录/未见电平）；已在 2026-03-08 补充保存兜底与电平可见性增强，需复测

### VRF-004
- feature: 记录页可找性优化（筛选 + 搜索 + 日期分组）
- description: 记录页应支持按范围筛选、关键词搜索，并按日期分组展示且每条显示时间，便于快速定位目标记录
- type: human-visual
- added: 2026-03-08
- status: pending
- notes: 用户新增期望：旧记录在上、首次打开自动定位到最底部最新记录；并要求降低单条占用空间；已改为紧凑行模式，需复测

### VRF-005
- feature: 记录与助手界面分离
- description: 记录与助手应在 UI 上分开展示（各自列表与输入语境分离），避免内容混杂
- type: human-visual
- added: 2026-03-08
- status: pending
- notes: 顶部分段切换后，记录面板只显示记录流；助手面板只显示助手流；输入栏文案与模式随面板变化

### VRF-006
- feature: 助手窗口线程化 + 修订历史保留
- description: 助手默认单窗口会话，确认记录后自动关闭并新建窗口；可重开历史窗口继续调整，且原记录时间不变并保留修订痕迹
- type: human-logic
- added: 2026-03-08
- status: pending
- notes: 验证路径建议为 助手会话 -> 记录到记录页 -> 自动新窗口 -> 打开历史窗口继续聊 -> 再确认后记录显示“已修订 N 次”且原时间不变

### VRF-007
- feature: 助手正常对话优先 + 手动整理记录
- description: 助手应先给出正常分析型回复（非纯复述）；记录确认卡需由用户主动点击“整理为记录”后才展开
- type: human-visual
- added: 2026-03-08
- status: pending
- notes: 验证路径为 助手发问 -> AI分析回复 -> 不自动弹记录卡 -> 点击“整理为记录”后出现待确认卡 -> 记录到记录页

### VRF-008
- feature: 首轮教练式回复（难点定位 + 错误原因 + 口腔训练）
- description: 用户第一次提问时，助手应给出具体发音难点和错误来源，并附带口腔训练与短时专项练习，而不是泛化复述
- type: human-logic
- added: 2026-03-08
- status: pending
- notes: 用 fan/fine 场景验证；若结构化回复偏泛化，系统应走本地增强逻辑输出可执行训练方案

### VRF-009
- feature: 助手通用 ChatGPT 式分析能力
- description: 助手应先理解用户目的并给出更深层分析与可执行建议；记录只作为后续沉淀，不应让助手退化为纯复述器
- type: human-logic
- added: 2026-03-08
- status: pending
- notes: 非发音主题也应有分析与行动建议；发音主题额外给口腔训练与对比练习

### VRF-010
- feature: 秘书型助手语气与输入约束一致性
- description: 助手应口语化、从用户目标出发给 why/how；且不得要求图片/文件/外部语音等当前不支持的输入方式
- type: human-visual
- added: 2026-03-08
- status: pending
- notes: 用“我总把 fan 和 fine 说混了”这类陈述句验证，首轮应主动分析并包含音标，不应要求额外媒体输入

### VRF-011
- feature: 助手去模板化（短自然首答 + 单一关键追问）
- description: 默认首答应为自然对话（约 3-5 句），不出现固定 Why/How/下一步编号模板；每轮最多一个关键追问
- type: human-logic
- added: 2026-03-08
- status: pending
- notes: 用短输入和连续追问验证上下文衔接，确认不会每轮重置成通用讲义；补充用例：单词级发音输入（如 crazy + 咬嘴）应直接给具体练法

### VRF-012
- feature: 助手意图分型与合同输出稳定性
- description: 助手应先判定输入意图（记录/分析/执行/决策/反思），并稳定输出“1核心原因 + 1最小动作 + 1成功标准”
- type: human-logic
- added: 2026-03-09
- status: pending
- notes: 验证“记进去”类输入应自动展开待确认记录卡（不自动提交）；默认回复长度应明显收敛，且不出现套话开场

### VRF-013
- feature: AI 回顾首轮结果与追问链
- description: 示例问题点击后应自动开始分析；首轮回答应先展示“事实 / 联系 / 可继续问”；继续追问 2-3 轮后界面仍保持可读，旧轮次默认折叠。
- type: human-visual
- added: 2026-03-22
- status: pending
- notes: 验证路径为 AI回顾 -> 点击示例问题 -> 查看首轮结果 -> 连续追问 2-3 次 -> 展开证据。

### VRF-014
- feature: 助手整理为记录全屏草稿确认流
- description: 助手“整理为记录”后应进入全屏草稿页；允许轻编辑标题与正文；仅在点击“确认记录”后才入库并触发后续拆分与标签。
- type: human-logic
- added: 2026-03-22
- status: pending
- notes: 验证路径为 记录 -> 助手 -> 一轮对话 -> 整理为记录 -> 轻编辑 -> 确认记录。

### VRF-015
- feature: 助手语音输入回线程
- description: 助手页语音输入完成后，应先转写，再自动把文本发送回当前助手线程并收到助手回复，不应停留在隐藏 capture 中。
- type: human-logic
- added: 2026-03-22
- status: pending
- notes: 验证路径为 记录 -> 助手 -> 麦克风录音 -> 停止 -> 等待转写 -> 确认进入当前对话线程。

### VRF-016
- feature: 标签建议与隐性标签维护
- description: 记录详情中推荐标签应可接受；Dev 的标签维护页应能重跑最近 10 条记录标签建议，并在隐性标签视图中看到结果；隐性标签标准化不应明显带偏 AI 回顾。
- type: human-logic
- added: 2026-03-22
- status: pending
- notes: 验证路径为 记录详情 -> 标签建议 -> 接受标签；Dev -> All Tags -> 重跑最近 10 条 -> 隐性 -> 整理隐性标签；再回 AI 回顾检查结果风格。

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

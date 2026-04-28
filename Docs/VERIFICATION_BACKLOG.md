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

### VRF-017
- feature: 助手语音输入单态录音 UI
- description: 助手页进入录音后，底部应只显示录音控制卡，不再与普通输入栏叠加；消息内容保持可读，`停止 / 取消` 层级清楚，转写后仍回当前线程。
- type: human-visual
- added: 2026-04-19
- status: pending
- notes: 验证路径为 记录 -> 助手 -> 开始录音 -> 观察底部单态录音卡 -> 停止录音 -> 确认转写回当前对话。

### VRF-018
- feature: 记录详情页编辑与删除入口
- description: 进入记录详情后，应能直接看到轻量的 `编辑` 与 `删除` 入口；编辑后内容更新并刷新列表，删除后详情关闭且记录从列表消失。
- type: human-logic
- added: 2026-04-19
- status: pending
- notes: 验证路径为 记录 -> 打开记录详情 -> 编辑保存 -> 返回检查列表刷新；再次进入详情 -> 删除 -> 确认记录消失。

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

### VRF-019
- feature: 记录详情页隐藏入口
- description: 在记录详情页点击 `隐藏` 后，记录应从记录列表中消失，但已有拆分结果和索引线索仍继续参与 AI 回顾与检索分析。
- type: human-logic
- added: 2026-04-19
- status: pending
- notes: 验证路径为 记录 -> 打开记录详情 -> 点击隐藏 -> 确认列表中消失；随后进入 AI 回顾，用应能命中的问题确认内容仍可参与分析。

### VRF-020
- feature: 记录页点空白收起键盘
- description: 在记录页唤起搜索框或底部输入框键盘后，点击列表区、对话区或空白区应自动收起键盘，同时不影响点开记录详情。
- type: human-visual
- added: 2026-04-20
- status: pending
- notes: 验证路径为 记录 -> 点搜索框或底部输入框 -> 点击输入区外的内容区域 -> 确认键盘收起；再点记录卡确认详情仍可打开。

### VRF-021
- feature: 系统信号参与 AI 回顾分析
- description: 日期、星期、时间段、输入来源和处理状态应作为系统信号进入 AI 回顾分析，但不应出现在普通标签或隐性标签列表里；只有 overview 回顾应因为这些结构化记录获得保底分析资格，focused 搜索仍需保持相关性过滤。
- type: human-logic
- added: 2026-04-24
- status: pending
- notes: 验证路径为 时间线 -> 打开只有少量已拆分记录的当天详情 -> 确认 AI 的回应可生成；再进入 Dev -> 全部标签确认没有日期/星期/输入来源标签；最后在 AI 回顾输入一个 focused 问题确认结果没有明显变宽。

### VRF-022
- feature: AI 回顾线索灵感入口
- description: AI 回顾首页应没有独立底部 `线索` Tab；当存在已有材料的显性线索时，应显示少量 `最近线索` 卡片。点击卡片应自动填入围绕该线索的问题并开始回顾，而不是只把文字放入输入框。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 AI 回顾 -> 空输入首页 -> 检查 `最近线索` 卡片视觉和数量 -> 点击一张线索卡 -> 确认进入加载/结果状态，时间筛选变为最近 90 天且线索筛选匹配该标签类型。

### VRF-023
- feature: Release/Archive Dev 隐藏巡检
- description: Release、Archive 或 TestFlight 安装包底部不应出现 `Dev`；Debug 清空本地状态后也不应默认出现 `Dev`，除非内部显式打开开发者菜单开关。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为安装最终构建 -> 打开 App -> 检查底部 Tab；预期只出现面向用户的主入口，不出现锤子/Dev。若使用 Debug 验证，需先清空 App 数据或确认 `feature.isDeveloperMenuVisible` 未被手动设为 true。

### VRF-024
- feature: AI 回顾首页线索优先入口
- description: AI 回顾首页应优先展示真实记录沉淀出的 `从这些线索开始` 区块，示例问题降级为辅助入口；点击线索卡或示例问题都应自动开始回顾，而不是只填入输入框。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 AI 回顾 -> 空输入首页。分别检查无记录/无线索、有 1-2 条线索、长线索名称、小屏首屏显示；点击线索卡应进入加载/结果状态，点击示例问题也应立即开始回顾。

### VRF-025
- feature: AI 回顾线索卡动态图标和副文案
- description: AI 回顾首页的线索卡应根据标签名称尽量显示更贴内容的图标、颜色和说明；未命中关键词时应稳定回退到标签类型图标，不影响点击即回顾。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 AI 回顾 -> 空输入首页。建议用 `工作安排`、`晨间启动`、`情绪波动`、`游戏段位`、`健身饮食` 等线索观察图标/副文案是否合理；点击卡片仍应自动进入 AI 回顾。

### VRF-026
- feature: 记录页顶部仅显示今天日期
- description: 记录页顶部应只保留 `今天 · 日期` 一行，不再显示已记录数量或解释性文案；切换到助手 surface 后顶部也不应重新出现辅助说明。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 记录 -> 查看顶部；切换记录/助手 segmented control；确认顶部只保留今天日期，下面直接进入范围筛选/搜索区域。

### VRF-027
- feature: 记录页和时间线页筛选入口一致性
- description: 记录页不应再显示 `回看范围`；时间线页不应再显示顶部 `时间线` 标题和说明文案。两个页面的范围筛选应成为顶部主要入口，边距和视觉重量保持一致。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 记录 -> 查看日期/筛选/搜索区域；切到 时间线 -> 查看顶部筛选区域；确认两页没有解释性标题残留，切换时不再有明显割裂感。

### VRF-028
- feature: 时间线页顶部日期与筛选一致性
- description: 时间线页顶部应和记录页一样显示 `今天 · yyyy/MM/dd`，下面直接是范围筛选；范围筛选不应显得过大或过小，和记录页的视觉节奏保持一致。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 记录 -> 观察日期和范围筛选；切到 时间线 -> 观察顶部日期和范围筛选；确认两页的横向边距、标题重量、筛选控件尺寸和上下间距没有明显割裂。时间线日期卡片仍应显示为 `M月d日 · 周几` 形式。

### VRF-029
- feature: 时间线筛选首项改为昨日
- description: 时间线页顶部范围筛选第一项应显示为 `昨日`，后两项应继续显示为 `7天回顾` 和 `30天回顾`；记录页筛选不应被影响。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 时间线 -> 查看顶部 segmented control；确认第一项为 `昨日`。再切到记录页，确认记录页范围筛选仍按原有文案显示。

### VRF-030
- feature: 记录页全部范围默认定位最新记录
- description: 记录页切换到 `全部` 时，应自动跳到最新一条记录附近，而不是显示最早记录；切换 `今天`、`近7天` 后也应优先定位该范围内最新条目。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 记录 -> 准备多天多条记录 -> 点击 `全部` -> 确认视口显示最新日期/最新记录；再切 `近7天` 和 `今天`，确认也定位最新条目。列表本身仍应保持从早到晚排列。

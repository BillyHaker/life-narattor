# Verification Backlog
project: Life Narrator
last-updated: 2026-05-02
next-milestone: TBD
pending-count: 38

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

### VRF-031
- feature: 记录页全部范围底部锚点滚动复验
- description: 在底部锚点实现后，记录页切换到 `全部` 应稳定落在最新记录附近，不应停在最早记录。该验证用于覆盖此前 UUID row scroll 未能生效的问题。
- type: human-visual
- added: 2026-04-28
- status: pending
- notes: 验证路径为 记录 -> 准备多天多条记录 -> 从 `今天` 切到 `全部` -> 确认视口落在最新日期/最新记录附近；反复切换 `近7天` / `全部`，确认不再回到最早记录。

### VRF-032
- feature: AI 第三方数据处理授权说明
- description: 新安装或旧版本升级后，如果尚未记录 `privacy.hasConsentedToAIProcessing`，用户应先看到 `隐私与 AI 处理说明`，页面需说明会发送哪些数据、发送给谁、用途是什么，并要求点击 `同意并继续` 后才能进入 App。
- type: human-visual
- added: 2026-04-29
- status: pending
- notes: 验证路径为清空 App 数据后启动；另用升级路径模拟 `app.hasSeenPrivacyIntro=true` 且 `privacy.hasConsentedToAIProcessing=false`。确认进入主界面前无法访问 AI 回顾、助手、语音转写等入口。

### VRF-033
- feature: Backend free/pro/reviewer AI quota rollout
- description: Production backend should default public users to `free`, allow selected user ids to become `pro` or `reviewer`, persist usage outside temp storage when `USAGE_STORE_PATH` is configured, and show tier/model/token information in `/admin`.
- type: backend-manual
- added: 2026-05-02
- status: superseded
- notes: 已被 `VRF-034` 的 AI 点数模型验证项取代。原 free/pro/reviewer 按次数额度已改为 trial/free/daily/deep/reviewer 按点数额度。

### VRF-034
- feature: AI credit model production rollout
- description: Backend should enforce monthly AI credits and return HTTP 402 `ai_credit_exhausted` when exhausted. The original trial/daily/deep paid-tier rollout is no longer the current product direction.
- type: backend-manual
- added: 2026-05-02
- status: superseded
- notes: 已被 `VRF-039` 的免费版月额度验证项取代。当前公开版本默认 `free`，不自动开启 7 天 trial，也不展示 daily/deep 付费档位。

### VRF-035
- feature: 用户设置页入口与内容
- description: 记录页日期右侧应出现设置按钮；点击后应打开设置页，显示 AI 与额度、隐私与 AI 处理、语音与权限、支持和版本信息。DevTools 不应出现在公开设置页中。
- type: human-visual
- added: 2026-05-02
- status: pending
- notes: 验证路径为 记录 -> 点击右上角设置按钮 -> 检查设置页布局和关闭行为；点击隐私政策、技术支持和系统权限设置入口，确认分别能打开对应页面。确认正式/公开界面没有暴露 DevTools 入口。

### VRF-036
- feature: 正式版设置页视觉层级
- description: 设置页应像正式产品设置中心，而不是开发说明页；顶部应显示 Life Narrator 方案状态卡，下面以短行分组显示 AI 与订阅、数据与隐私、语音、帮助与关于。暂未接入的功能应显示克制状态，不应让用户误以为立即可用。
- type: human-visual
- added: 2026-05-02
- status: pending
- notes: 验证路径为 记录 -> 设置。确认顶部卡片、分组标题、行图标、状态文字和链接行为自然；确认 `管理订阅`、`自带 API`、`导出数据` 等未来能力文案不会造成误导；确认隐私政策、技术支持和系统设置入口可打开。

### VRF-037
- feature: App 图标清新简约替换
- description: App 图标应在 iOS 主屏幕、Spotlight、小尺寸通知/设置场景下保持清晰，整体风格应简约、清新、轻量，不应出现文字、透明通道或复杂细节。
- type: human-visual
- added: 2026-05-02
- status: pending
- notes: 验证路径为安装到模拟器或真机 -> 回到主屏幕查看图标；再执行 Archive/Validate，确认 App Store 不再报告 icon alpha 或尺寸问题。

### VRF-038
- feature: Release AI backend configuration and in-app feedback
- description: Public/App Store builds should use a configured public HTTPS AI backend instead of debug-only local config; Settings and AI failure states should expose `反馈问题`; feedback should submit description, optional contact, optional screenshot, and be visible in backend admin.
- type: backend-manual
- added: 2026-05-02
- status: pending
- notes: 验证路径为部署 backend -> 将 HTTPS base URL 写入 `Life Narattor/AppConfig.plist` 的 `AIBaseURL` -> Archive/安装新构建 -> 验证记录拆分、助手、AI 回顾不再提示 AI 服务不可用 -> 设置页提交反馈（含截图）-> 打开 `/admin/feedback` 确认能看到反馈。当前已自动验证本地 backend smoke、Debug build、Release simulator build、Xcode test；公网部署和真机/商店包行为仍需人工验证。

### VRF-039
- feature: 免费版 AI 月额度
- description: 公开 backend 默认新用户为 `free`，每月有免费 AI 点数；额度耗尽时返回 HTTP 402 `ai_credit_exhausted`，App 应显示友好的免费额度用完提示；设置页应说明当前只有免费版，订阅暂未开放。
- type: backend-manual + human-visual
- added: 2026-05-03
- status: pending
- notes: 验证路径为部署 backend 且不设置 `USAGE_DEFAULT_TIER` -> 用新 user id 触发 AI 请求 -> 打开 `/admin/users/<id>` 检查 tier 为 `free`、月额度为 300。 staging 环境可临时设置 `USAGE_CREDIT_LIMIT_OVERRIDES={"free":3}` 后触发超额，确认 App 提示“本月免费 AI 额度已用完，下月会自动恢复”。设置页应显示 `免费版`、`每月免费额度`，且不出现 `7 天试用` 或可管理订阅入口。

### VRF-040
- feature: iCloud 私有同步与重装恢复
- description: 文字记录、转写、整理结果、拆分结构和标签应通过用户自己的 iCloud 私有数据库恢复；删除 App 或换同 Apple ID 设备后，应能恢复这些结构化数据。原始录音文件当前不承诺跨设备恢复。
- type: signed-device-manual
- added: 2026-05-03
- status: pending
- notes: 验证路径为确认 Apple Developer/Xcode 已启用 iCloud + CloudKit container `iCloud.com.jintaoha.Life-Narattor` -> 安装签名包到已登录 iCloud 的真机 A -> 创建文字和语音记录并完成整理/拆分 -> 等待 CloudKit 同步 -> 删除重装或在真机 B 同 Apple ID 安装 -> 确认记录、转写、整理结果、拆分片段、显性/隐性标签恢复。另在未登录 iCloud 状态下打开设置页，确认提示为 `未检测到可用 iCloud`。

### VRF-041
- feature: 三步初始使用引导
- description: 首次完成隐私与 AI 处理同意后，应出现三步产品引导；用户可以跳过，也可以逐步完成并通过 `开始记一句` 进入记录页；设置页应能重新打开该引导。
- type: human-visual
- added: 2026-05-06
- status: pending
- notes: 验证路径为清空或重置 `app.hasSeenProductGuide` -> 启动 App -> 完成隐私同意 -> 检查三页文案与按钮；点击 `先进入看看` 和最后一页 `开始记一句` 都应进入记录页。再进入 设置 -> `重新看使用引导`，确认可以复看。小屏设备需确认卡片文字和底部按钮不重叠。

### VRF-042
- feature: 记录详情拆分说明卡
- description: 用户首次进入记录详情的 `拆分` tab 时，应看到一个轻量说明卡，解释记录会如何拆成片段并用于时间线和 AI 回顾；点击 `知道了` 或关闭后不应重复打扰。
- type: human-visual
- added: 2026-05-06
- status: pending
- notes: 验证路径为清空或重置 `app.hasSeenAtomSplitHint` -> 打开任意记录详情 -> 切换到 `拆分` -> 确认说明卡出现；点击关闭后重新打开记录详情，确认说明卡不再出现。有拆分结果和无拆分结果两种状态都应检查。

### VRF-043
- feature: 记录页底部输入栏与助手模式
- description: 记录页底部不应再显示独立的 `记录 / 助手` 分段导航；助手应作为输入栏里的轻量模式按钮出现。切换助手后，页面进入助手会话语境，placeholder 改为助手输入，并且发送内容走助手流程；切回后普通输入仍创建记录。主 Tab Bar 在 Pro Max 上应比旧版更舒展，不与输入栏争抢层级。
- type: human-visual
- added: 2026-05-08
- status: pending
- notes: 验证路径为启动 App -> 记录页 -> 检查底部只有输入栏和三栏主 Tab Bar；点击 `助手` 按钮，确认助手会话出现并可发送；再次点击 `助手` 切回记录，确认筛选和记录列表恢复；弹出键盘、开始录音、切换根 Tab，确认底部控件不重叠。自动验证：Debug simulator build passed；xcodebuild test 因 CoreSimulatorService 不可用未运行。

### VRF-044
- feature: 恢复记录页三层底部控件并放大主导航
- description: 记录页底部应显示三层结构：`记录 / 助手` 分段切换、`麦克风 / 输入栏 / 发送` 输入行、以及更宽更大的 `记录 / 时间线 / AI 回顾` 主导航。输入栏里不应再出现内联 `助手` 小按钮。
- type: human-visual
- added: 2026-05-08
- status: pending
- notes: 验证路径为启动 App -> 记录页 -> 检查三层结构；点击 `助手` 进入助手会话，点击 `记录` 返回记录列表；弹出键盘和开始录音时检查三层控件不重叠。重点在 Pro Max 上确认主导航胶囊接近占满屏幕宽度且不显小。

### VRF-045
- feature: 记录页输入栏避让底部主导航
- description: 在恢复三层底部结构后，`麦克风 / 输入栏 / 发送` 输入行必须完整显示在 `记录 / 时间线 / AI 回顾` 主导航上方，不应被主导航遮挡。录音状态的 `RecordingChipView` 也需要同样避让。
- type: human-visual
- added: 2026-05-08
- status: pending
- notes: 验证路径为启动 App -> 记录页 -> 检查三层底部控件；点击 `助手` 和 `记录` 来回切换；点击麦克风开始录音；弹出键盘。通过标准是输入行和录音条始终完整可见，主导航仍保持更宽的胶囊外观。

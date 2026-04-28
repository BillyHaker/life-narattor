# 测试版提审前准备工作清单

Last updated: 2026-04-28
Status: Submission preflight checklist

## 目标
这份清单用于把当前 TestFlight / App Review 前的收尾事项压到可验证状态。它不是长期 roadmap，只关注测试版能否安全、稳定、清晰地交给第一批用户。

## 一、提审前必须完成

### A. 产品边界
- [x] `AI 回顾` 是回顾 Tab 的主入口，默认进入可提问的 AI 回顾界面。
- [x] 旧的周/月回顾入口不出现在主路径；遗留 screen 已改为滚动 `7 天回顾` / `30 天回顾` 口径。
- [x] 时间线的周期入口使用 `7天回顾` / `30天回顾`，不再用容易误解的自然周/自然月文案。
- [x] Dev Tab 在 `#if DEBUG` 下编译，Release/TestFlight 不显示；Debug 运行也默认隐藏，只有内部开关显式打开时才显示。
- [x] 面向用户的推荐标签系统已关闭，不作为本版测试范围。

### B. AI 与转写安全边界
- [x] Release/TestFlight 只允许通过 backend proxy 使用 AI 服务。
- [x] Release/TestFlight 不再使用客户端本地 OpenAI API key fallback。
- [x] Release/TestFlight 的语音转写优先使用 AI/backend 转写，不回退到本地识别造成假成功。
- [x] backend 默认转写提供方为 Doubao；OpenAI 转写保留为 backend 可配置备选，不暴露给客户端。
- [x] App 首屏隐私说明明确：默认本地保存；主动使用 AI/转写/整理/回顾时才通过后台代理处理必要内容。
- [x] App 不把上游模型服务密钥放进应用或发给测试用户。

### C. 核心用户路径
- [ ] 文本记录创建、查看、编辑正常。
- [ ] 语音记录创建、转写、整理文本查看正常。
- [ ] 助手文本对话正常。
- [ ] 助手语音输入正常，转写后能发回当前助手线程。
- [ ] 助手“整理为记录”打开全屏草稿页，确认后才入库。
- [ ] 记录详情页：原始 / 整理后 / 拆分 三个 tab 基本可用。
- [ ] 重新转写 / 重新整理 / 重新拆分 各自行为正确，不串链路。
- [ ] 记录列表左滑删除 / 隐藏行为正确：隐藏不展示在记录列表，但拆分材料仍可参与分析。
- [ ] 点击输入法外区域可收起键盘。

### D. AI 回顾与时间线
- [ ] `AI 回顾`：示例问题点击后自动开始分析。
- [ ] `AI 回顾`：首轮输出为事实、联系、可继续问，不是长报告。
- [ ] `AI 回顾`：继续追问以聊天气泡展示，不压坏首屏阅读。
- [ ] 自然语言检索能正确处理“过去一周/最近7天/过去30天”等常见时间表达。
- [ ] 时间线 `今天` 展示当天片段和昨日故事线入口。
- [ ] 时间线 `7天回顾` / `30天回顾` 使用对应周期材料生成故事线，不只是列出日期。
- [ ] 时间线在没有可用故事线时展示轻量等待文案，不误报“系统无法分析”。

### E. 构建与稳定性
- [ ] Debug 构建通过。
- [ ] Release 构建通过，用于确认 TestFlight 编译分支可用。
- [ ] 如果测试 target 可运行，测试通过。
- [ ] Release/Archive 产物安装后底部 Tab 不出现 `Dev`。
- [ ] Archive validation 通过，且选中正确构建版本。
- [ ] backend proxy 关键路由可用：`/v1/chat`, `/v1/transcribe`, `/admin`。
- [ ] 没有明显假成功：AI 未配置时明确失败，而不是返回 mock 结果。
- [ ] 关键路径不出现明显卡死、重复请求或状态残留。

## 二、建议提审前完成

### A. 标签和回顾质量
- [ ] 隐性标签生成可在 Debug/Dev 中检查。
- [ ] 隐性标签标准化 mapping 至少跑过一轮，确认不会明显带偏 AI 回顾。
- [ ] 用固定 AI 回顾样例验证输出风格，见 `Docs/06_Testing/AI-Review-Evaluation-Samples.md`。

### B. 后台与测试运营
- [ ] admin 后台可查看用户、usage、邀请码。
- [ ] 邀请码生成和注册链路可用。
- [ ] 测试用户配额已启用。
- [ ] 邮件发送链路可以延后，但邀请码与邮箱记录需要可追溯。

### C. App Store Connect
- [ ] 隐私政策 URL 可访问。
- [ ] 技术支持 URL 可访问。
- [ ] App 隐私信息按当前实际数据处理方式填写。
- [ ] 价格、分类、描述、关键词、审核备注已填写。
- [ ] 截图尺寸符合 App Store Connect 要求。
- [ ] 已选择构建版本，且版本号 / build number 与本次提交一致。
- [ ] 审核备注说明 AI 功能需要联网、测试账号/邀请码方式、以及 Dev 工具不会出现在 Release。

## 二点五、2026-04-28 复查发现的易忽略项

这些不是新功能，但属于提交前容易漏掉的门面和运营准备项：

- [ ] 用 Release 配置或 Archive 安装包做一次完整视觉巡检，确认底部只有 `记录 / 时间线 / AI 回顾`，不出现 `Dev`。
- [ ] App Store Connect 的 `App 隐私` 需要和当前真实数据流一致：本地记录默认本地保存；AI/转写/整理/回顾会通过后台代理处理必要内容；admin/usage 只做测试运营统计。
- [ ] 技术支持 URL、隐私政策 URL 都需要公网可访问，不能只是在本地或 GitHub 私有仓库里。
- [ ] 选定一个最终 archive build 后重新跑 validation；此前图标和截图问题已经出现过，不能只依赖 Xcode Debug build。
- [ ] 后台生产环境至少确认健康检查、邀请码/注册、usage 计数、日额度限制和超额提示。
- [ ] 准备一段简短审核备注，说明测试用户如何进入、AI 功能如何触发、没有付费墙、没有暴露 provider key。
- [ ] 准备一份 5-10 分钟人工 smoke test 记录：文本记录、语音转写、助手、整理为记录、AI 回顾、时间线、无 Dev。

## 三、本版明确延后
- [x] 用户自带 AI API 模式。
- [x] 完整云同步 / 内容恢复。
- [x] 正式运营级邮件邀请自动化。
- [x] 高级 admin 操作，例如人工调额度、封禁、分组。
- [x] 面向用户的标签推荐选择流程。

## 四、手动验收顺序

1. 记录链：创建文本记录，创建语音记录，打开详情页，验证重新整理 / 重新拆分 / 重新转写。
2. 助手链：文本对话，语音对话，整理为记录，草稿轻编辑，确认入库。
3. AI 回顾链：点击示例问题，查看事实/联系/可继续问，展开证据，连续追问 2-3 轮。
4. 时间线链：查看今天、7天回顾、30天回顾；确认周期故事线和每日卡片口径一致。
5. 隐私链：首次启动看到隐私说明；Release/TestFlight 不出现 Dev；无客户端模型密钥入口。
6. 后台链：打开 admin，查看 usage 总览，生成邀请码，验证注册入口。

## 五、检测方案

### 自动检测
- `xcodebuild -project "Life Narattor.xcodeproj" -scheme "Life Narattor" -destination "generic/platform=iOS Simulator" build`
- `xcodebuild -project "Life Narattor.xcodeproj" -scheme "Life Narattor" -configuration Release -destination "generic/platform=iOS Simulator" build`
- 如果测试 target 可用，运行 `Life NarattorTests`。
- `rg "AIService=OpenAI|DevToolsRootView" "Life Narattor"` 确认直连模型与 Dev 工具只存在于调试边界内。
- `rg "TRANSCRIBE_PROVIDER=openai" server` 应无结果，确认 Doubao 仍是默认转写提供方。

### 人工检测
- 在 Debug 中确认 Dev 可见，在 Release/TestFlight 构建中确认底部 Tab 没有 Dev。
- 在没有 backend 配置的 Release 构建中触发 AI 功能，应明确不可用，不应回落到本地 key 或 mock。
- 在 backend 配置 Doubao 后触发语音转写，应从后台完成转写并记录 usage。
- 用固定回顾样例问同一组问题，检查 AI 回顾是否引用事实、提出联系、允许继续追问。

## 六、完成标准

这份 preflight 可视为完成，当且仅当：
- `提审前必须完成` 全部通过或有明确延期说明。
- Release/TestFlight 没有 Dev、没有客户端模型密钥、没有 mock AI。
- 核心记录、助手、AI 回顾、时间线路径手动走通。
- 构建通过，失败项已记录到 verification backlog 或本清单。

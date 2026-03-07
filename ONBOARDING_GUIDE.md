# Life Narrator 项目交接文档 - AI 开发团队阅读指南

**文档版本**: 1.0
**最后更新**: 2026-03-06
**项目状态**: 开发中，核心功能已实现
**预计阅读时间**: 2-3 小时（完整阅读），30 分钟（快速上手）

---

## 📋 目录

1. [快速上手路径](#快速上手路径-30-分钟)
2. [完整阅读路径](#完整阅读路径-2-3-小时)
3. [项目结构概览](#项目结构概览)
4. [关键文档索引](#关键文档索引)
5. [开发工作流程](#开发工作流程)
6. [当前状态与待办事项](#当前状态与待办事项)
7. [常见问题解答](#常见问题解答)

---

## 快速上手路径 (30 分钟)

如果你需要立即开始工作，按以下顺序阅读：

### 第一步：了解规则 (5 分钟)
1. **`README.md`** - 项目概述和基本说明
2. **`Rules/AI_RULES.md`** - AI 开发的核心规则（必读！）
3. **`Rules/DEV_LOG_RULES.md`** - 开发日志规范（如何记录工作）

### 第二步：了解产品 (10 分钟)
1. **`Skills/product-northstar/SKILL.md`** - 产品定位和核心价值
2. **`Skills/user-scenarios/SKILL.md`** - 用户场景和使用流程
3. **`Docs/01_Product/Placeholder_Features.md`** - 功能清单和开发状态

### 第三步：了解架构 (10 分钟)
1. **`Skills/database-schema/SKILL.md`** - 数据库设计（Core Data）
2. **`Skills/ai-interaction/SKILL.md`** - AI 集成架构
3. **`Docs/03_Decisions/ADR-001-coredata-v1.md`** - 核心数据架构决策

### 第四步：了解当前问题 (5 分钟)
1. **`THREADING_FIX_FINAL.md`** - 最新修复的详情页卡死问题
2. **`COMPLIANCE_FIX_SUMMARY.md`** - 最近的合规性修复总结
3. **`Docs/04_Sessions/2026-03-06_session-001.md`** - 最新工作会话

### 立即开始
- 打开 Xcode 项目: `Life Narattor.xcodeproj`
- 运行项目: Cmd+R
- 查看 DevTools: 在应用中导航到开发者工具

---

## 完整阅读路径 (2-3 小时)

按照以下顺序深入理解整个项目：

### 阶段 1：基础设施与规则 (30 分钟)

#### 1.1 项目根目录文档
- [ ] **`README.md`** - 项目概述
- [ ] **`Rules/AI_RULES.md`** - AI 开发核心规则
- [ ] **`Rules/DEV_LOG_RULES.md`** - 开发日志规范
- [ ] **`Rules/WORKFLOW.md`** - 标准开发流程
- [ ] **`Rules/CONTEXT.md`** - 上下文管理规则
- [ ] **`Rules/PLAN_TEMPLATE.md`** - 规划模板
- [ ] **`Rules/REVIEW_CHECKLIST.md`** - 代码审查清单
- [ ] **`Rules/SECURITY.md`** - 安全基线

#### 1.2 模板文件
- [ ] **`Templates/SESSION_LOG_TEMPLATE.md`** - 会话日志模板
- [ ] **`Templates/ADR_TEMPLATE.md`** - 架构决策记录模板
- [ ] **`Templates/CHANGELOG_TEMPLATE.md`** - 变更日志模板
- [ ] **`Templates/HANDOVER_TEMPLATE.md`** - 交接文档模板

### 阶段 2：产品定位与设计 (30 分钟)

#### 2.1 产品核心文档
- [ ] **`Skills/product-northstar/SKILL.md`** - 产品北极星（必读）
  - 产品定位：AI 驱动的个人生活记录器
  - 核心价值：自动整理、智能拆分、标签管理
  - 目标用户：需要高效记录和回顾生活的个人用户

- [ ] **`Skills/user-scenarios/SKILL.md`** - 用户场景
  - 快速记录场景（文字/语音）
  - 查看和回顾场景
  - 搜索和标签管理场景

- [ ] **`Docs/01_Product/Placeholder_Features.md`** - 功能清单
  - 已实现功能列表
  - 占位功能列表
  - 待开发功能优先级

#### 2.2 UI/UX 规范
- [ ] **`Skills/ia-navigation/SKILL.md`** - 信息架构和导航
  - Tab 结构：记录、时间线、回顾、项目、搜索
  - 导航流程和层级关系

- [ ] **`Skills/capture-ui/SKILL.md`** - 记录输入界面
  - 文字输入设计
  - 语音输入设计
  - 快速确认流程

- [ ] **`Skills/ui-pattern-library/SKILL.md`** - UI 组件库
  - 卡片样式
  - 标签样式
  - 按钮和交互规范

### 阶段 3：核心技术架构 (45 分钟)

#### 3.1 数据层
- [ ] **`Skills/database-schema/SKILL.md`** - 数据库设计（核心）
  - Core Data 实体设计
  - 关系定义
  - 迁移策略

- [ ] **`Docs/03_Decisions/ADR-001-coredata-v1.md`** - Core Data 架构决策
- [ ] **`Docs/03_Decisions/ADR-004-atom-tag-coredata.md`** - Atom 和 Tag 关系设计
- [ ] **`Docs/03_Decisions/ADR-006-voice-transcription-schema.md`** - 语音转写数据模型

#### 3.2 AI 集成
- [ ] **`Skills/ai-interaction/SKILL.md`** - AI 服务集成（核心）
  - AI 服务抽象层设计
  - OpenAI/Backend/Mock 三种模式
  - API 调用流程

- [ ] **`Skills/atomization/SKILL.md`** - 自动拆分功能（核心）
  - 拆分规则和类型
  - 源文本追溯（startChar/endChar）
  - 版本管理

- [ ] **`Skills/tags/SKILL.md`** - 智能标签建议
  - 标签类型：项目、主题、人物、目标
  - 可见建议 vs 隐藏建议
  - 标签分配规则

- [ ] **`Skills/clean-defiller/SKILL.md`** - 文本清理
  - 口语化去除（"嗯"、"啊"）
  - 保留核心语义

- [ ] **`Skills/speech-transcription/SKILL.md`** - 语音转写
  - 转写状态管理
  - 错误处理

- [ ] **`Docs/03_Decisions/ADR-007-openai-client-key-dev-only.md`** - OpenAI 开发配置
- [ ] **`Docs/03_Decisions/ADR-008-backend-proxy-for-ai.md`** - 后端代理架构
- [ ] **`Docs/03_Decisions/ADR-009-ai-atomization-tag-suggestions.md`** - AI 拆分和标签流程

#### 3.3 核心业务逻辑
- [ ] **`Skills/assist-archive-card/SKILL.md`** - 辅助归档卡片
- [ ] **`Skills/daily-narrative-two-layer/SKILL.md`** - 每日叙事双层结构
- [ ] **`Skills/timeline-browse/SKILL.md`** - 时间线浏览
- [ ] **`Skills/review-memory/SKILL.md`** - 回顾与记忆系统
- [ ] **`Skills/project-review/SKILL.md`** - 项目回顾
- [ ] **`Skills/search/SKILL.md`** - 搜索功能

### 阶段 4：开发工具与调试 (20 分钟)

#### 4.1 开发者工具
- [ ] **`Skills/devtools-debug-suite/SKILL.md`** - 调试套件（重要）
  - AI Debug 日志查看
  - Core Data 查看器
  - 诊断导出功能

- [ ] **`Skills/privacy-redaction-standard/SKILL.md`** - 隐私脱敏标准
  - P0/P1/P2 数据分类
  - 脱敏规则

- [ ] **`Skills/dev-logging-system/SKILL.md`** - 日志系统
- [ ] **`Skills/feature-flags-governance/SKILL.md`** - 特性开关管理

- [ ] **`Docs/03_Decisions/ADR-003-devtools-debug-suite.md`** - DevTools 架构决策
- [ ] **`Docs/03_Decisions/ADR-001-privacy-redaction-architecture.md`** - 隐私脱敏架构

#### 4.2 测试与质量
- [ ] **`Skills/acceptance-testing-min-bar/SKILL.md`** - 验收测试标准
- [ ] **`Rules/TDD_GUIDE.md`** - TDD 指南
- [ ] **`MANUAL_TEST_CHECKLIST.md`** - 手动测试清单

### 阶段 5：最近的工作历史 (25 分钟)

#### 5.1 最新修复（关键）
- [ ] **`THREADING_FIX_FINAL.md`** - 详情页卡死问题修复（最新）
  - 问题：`@MainActor` 阻塞主线程
  - 解决：移除 `@MainActor`，使用 `MainActor.run { }`
  - 影响文件：`AtomizationCoordinator.swift`, `CaptureDetailSheet.swift`

- [ ] **`URGENT_FIX_DETAIL_FREEZE.md`** - 卡死问题详细分析
  - 第一次修复（失败）：`.onAppear` → `.task`
  - 第二次修复（成功）：线程模型重构

- [ ] **`COMPLIANCE_FIX_SUMMARY.md`** - 合规性修复总结
  - 7 个合规问题修复
  - 隐私脱敏增强
  - 源文本追溯实现

- [ ] **`FREEZE_DIAGNOSIS.md`** - 输入卡死问题诊断

#### 5.2 最近会话日志（选读 2-3 个最新的）
- [ ] **`Docs/04_Sessions/2026-03-06_session-001.md`** - 合规性修复会话
- [ ] **`Docs/04_Sessions/2026-03-05_session-043.md`**
- [ ] **`Docs/04_Sessions/2026-03-04_session-042.md`**

查看会话日志时，关注：
- **Goal** - 会话目标
- **Work Log** - 工作流程
- **Handover Notes** - 交接说明

#### 5.3 最近变更日志（选读 3-5 个最新的）
- [ ] **`Docs/05_Changes/Change-048-ai-atomization-debug.md`**
- [ ] **`Docs/05_Changes/Change-047-openai-test-strict.md`**
- [ ] **`Docs/05_Changes/Change-046-devtools-keychain-key.md`**
- [ ] **`Docs/05_Changes/Change-001-atomization-compliance-fixes.md`** - 合规性修复详情

查看变更日志时，关注：
- **Summary** - 变更摘要
- **Files Changed** - 修改文件列表
- **Verification Steps** - 验证步骤
- **Rollback Notes** - 回滚说明

### 阶段 6：代码结构理解 (10 分钟)

浏览代码文件夹结构，了解代码组织方式：

#### 6.1 核心代码结构
```
Life Narattor/
├── AI/                     # AI 服务层
│   └── AIService.swift     # AI 服务抽象和实现
├── Data/                   # 数据层
│   ├── *Entity.swift       # Core Data 实体定义
│   ├── PersistenceController.swift  # Core Data 配置
│   ├── AtomTagStore.swift  # Atom/Tag 仓库
│   └── AtomizationCoordinator.swift # 拆分协调器
├── Models/                 # 视图模型
│   ├── CaptureItem.swift   # 记录模型
│   ├── AtomItem.swift      # Atom 模型
│   └── *Models.swift       # 其他模型
├── ViewModels/             # 视图模型层
│   └── CaptureFeedViewModel.swift
├── Views/                  # 可复用视图组件
│   ├── CaptureCardView.swift
│   ├── CaptureDetailSheet.swift
│   └── *.swift
├── Screens/                # 页面级视图
│   ├── RecordFeedScreen.swift      # 记录页面
│   ├── TimelineScreen.swift        # 时间线页面
│   ├── ReviewHomeScreen.swift      # 回顾页面
│   ├── ProjectsListScreen.swift    # 项目页面
│   └── SearchScreen.swift          # 搜索页面
├── DevTools/               # 开发者工具
│   ├── DevToolsRootView.swift
│   ├── AIDebugStore.swift
│   └── *.swift
└── Life_NarattorApp.swift  # 应用入口
```

#### 6.2 关键代码文件（按重要性）
1. **`AIService.swift`** - AI 服务核心
2. **`AtomizationCoordinator.swift`** - 拆分协调器（最新修复）
3. **`AtomTagStore.swift`** - 数据仓库
4. **`CaptureDetailSheet.swift`** - 详情页视图（最新修复）
5. **`PersistenceController.swift`** - Core Data 配置
6. **`CaptureFeedViewModel.swift`** - 记录页视图模型

---

## 项目结构概览

### 根目录文件和文件夹

```
Life Narattor/
├── README.md                           # 项目说明（入口）
├── ONBOARDING_GUIDE.md                 # 本文档
│
├── 最新修复文档（优先阅读）
├── THREADING_FIX_FINAL.md              # 详情页卡死修复（最新）
├── URGENT_FIX_DETAIL_FREEZE.md         # 卡死问题详细分析
├── COMPLIANCE_FIX_SUMMARY.md           # 合规性修复总结
├── FREEZE_DIAGNOSIS.md                 # 输入卡死诊断
├── MANUAL_TEST_CHECKLIST.md            # 手动测试清单
│
├── Rules/                              # 开发规则（必读）
│   ├── AI_RULES.md                     # AI 开发核心规则 ⭐
│   ├── DEV_LOG_RULES.md                # 开发日志规范 ⭐
│   ├── WORKFLOW.md                     # 标准工作流程
│   ├── CONTEXT.md                      # 上下文管理
│   ├── PLAN_TEMPLATE.md                # 规划模板
│   ├── TDD_GUIDE.md                    # TDD 指南
│   ├── REVIEW_CHECKLIST.md             # 代码审查
│   └── SECURITY.md                     # 安全基线
│
├── Templates/                          # 文档模板
│   ├── SESSION_LOG_TEMPLATE.md         # 会话日志模板
│   ├── ADR_TEMPLATE.md                 # 架构决策模板
│   ├── CHANGELOG_TEMPLATE.md           # 变更日志模板
│   └── HANDOVER_TEMPLATE.md            # 交接文档模板
│
├── Skills/                             # 功能规范（详细）
│   ├── SKILLS_INDEX.md                 # Skills 索引
│   ├── product-northstar/              # 产品定位 ⭐
│   ├── user-scenarios/                 # 用户场景 ⭐
│   ├── database-schema/                # 数据库设计 ⭐
│   ├── ai-interaction/                 # AI 集成 ⭐
│   ├── atomization/                    # 自动拆分 ⭐
│   ├── tags/                           # 标签系统 ⭐
│   ├── clean-defiller/                 # 文本清理
│   ├── speech-transcription/           # 语音转写
│   ├── capture-ui/                     # 记录界面
│   ├── ia-navigation/                  # 信息架构
│   ├── assist-archive-card/            # 归档卡片
│   ├── daily-narrative-two-layer/      # 每日叙事
│   ├── timeline-browse/                # 时间线
│   ├── review-memory/                  # 回顾系统
│   ├── project-review/                 # 项目回顾
│   ├── search/                         # 搜索功能
│   ├── devtools-debug-suite/           # 调试工具 ⭐
│   ├── privacy-redaction-standard/     # 隐私脱敏 ⭐
│   ├── dev-logging-system/             # 日志系统
│   ├── feature-flags-governance/       # 特性开关
│   ├── ui-pattern-library/             # UI 组件库
│   └── ... (其他 Skills)
│
├── Docs/                               # 项目文档
│   ├── 00_Index/                       # 索引和设置
│   ├── 01_Product/                     # 产品文档
│   │   └── Placeholder_Features.md     # 功能清单 ⭐
│   ├── 02_Architecture/                # 架构文档
│   ├── 03_Decisions/                   # 架构决策记录 (ADRs)
│   │   ├── ADR-001-coredata-v1.md      # Core Data 架构 ⭐
│   │   ├── ADR-001-privacy-redaction-architecture.md  # 隐私架构 ⭐
│   │   ├── ADR-004-atom-tag-coredata.md
│   │   ├── ADR-007-openai-client-key-dev-only.md
│   │   ├── ADR-008-backend-proxy-for-ai.md
│   │   └── ... (9 个 ADRs)
│   ├── 04_Sessions/                    # 工作会话日志
│   │   ├── 2026-03-06_session-001.md   # 最新会话 ⭐
│   │   └── ... (46 个会话日志)
│   ├── 05_Changes/                     # 变更日志
│   │   ├── Change-001-atomization-compliance-fixes.md  # 合规修复 ⭐
│   │   └── ... (48 个变更日志)
│   ├── 06_Testing/                     # 测试文档
│   └── 99_Handover/                    # 交接文档
│
├── Life Narattor/                      # Xcode 项目（源代码）
│   ├── AI/                             # AI 服务层
│   ├── Data/                           # 数据层（Core Data）
│   ├── Models/                         # 数据模型
│   ├── ViewModels/                     # 视图模型
│   ├── Views/                          # 可复用视图
│   ├── Screens/                        # 页面视图
│   ├── DevTools/                       # 开发者工具
│   ├── DevToolsSupport/                # 开发工具支持
│   ├── Assets.xcassets                 # 资源文件
│   ├── ContentView.swift               # 主视图
│   └── Life_NarattorApp.swift          # 应用入口
│
├── Life Narattor.xcodeproj/            # Xcode 项目配置
├── Life NarattorTests/                 # 单元测试
├── Life NarattorUITests/               # UI 测试
│
├── seed_pack_v3/                       # Seed Pack V3（通用框架）
│   ├── Rules/                          # 通用规则
│   ├── Skills/                         # 通用 Skills
│   ├── Templates/                      # 通用模板
│   └── Docs/                           # 通用文档
│
└── server/                             # 后端服务（可选）
```

### 文件夹说明

#### 核心文件夹（必须理解）
- **`Rules/`** - 开发规则和规范，所有 AI 开发必须遵守
- **`Skills/`** - 功能规范，每个功能的详细定义和验收标准
- **`Docs/03_Decisions/`** - 架构决策记录，理解为什么这样设计
- **`Docs/04_Sessions/`** - 工作会话日志，了解开发历史
- **`Docs/05_Changes/`** - 变更日志，每次修改的详细记录
- **`Life Narattor/`** - 源代码

#### 辅助文件夹（按需查阅）
- **`Templates/`** - 文档模板
- **`Docs/01_Product/`** - 产品需求
- **`Docs/06_Testing/`** - 测试相关
- **`seed_pack_v3/`** - 通用框架（不常改动）
- **`server/`** - 后端服务（可选）

---

## 关键文档索引

### 按优先级分类

#### P0 - 立即阅读（必须）
1. **`Rules/AI_RULES.md`** - AI 开发核心规则
2. **`Rules/DEV_LOG_RULES.md`** - 开发日志规范
3. **`Skills/product-northstar/SKILL.md`** - 产品定位
4. **`Skills/database-schema/SKILL.md`** - 数据库设计
5. **`Skills/ai-interaction/SKILL.md`** - AI 集成
6. **`Skills/atomization/SKILL.md`** - 自动拆分
7. **`THREADING_FIX_FINAL.md`** - 最新修复

#### P1 - 尽快阅读（重要）
1. **`Skills/tags/SKILL.md`** - 标签系统
2. **`Skills/user-scenarios/SKILL.md`** - 用户场景
3. **`Skills/devtools-debug-suite/SKILL.md`** - 调试工具
4. **`Skills/privacy-redaction-standard/SKILL.md`** - 隐私脱敏
5. **`Docs/01_Product/Placeholder_Features.md`** - 功能清单
6. **`Docs/03_Decisions/ADR-001-coredata-v1.md`** - Core Data 架构
7. **`COMPLIANCE_FIX_SUMMARY.md`** - 合规性修复

#### P2 - 按需阅读（有用）
1. **`Skills/capture-ui/SKILL.md`** - 记录界面
2. **`Skills/ia-navigation/SKILL.md`** - 信息架构
3. **`Skills/timeline-browse/SKILL.md`** - 时间线
4. **`Skills/search/SKILL.md`** - 搜索功能
5. **`Docs/04_Sessions/2026-03-06_session-001.md`** - 最新会话
6. **其他 Skills/** - 各功能详细规范
7. **其他 ADRs/** - 各架构决策

### 按类型分类

#### 规则与规范
- `Rules/AI_RULES.md` - AI 开发规则
- `Rules/DEV_LOG_RULES.md` - 日志规范
- `Rules/WORKFLOW.md` - 工作流程
- `Rules/TDD_GUIDE.md` - TDD 指南
- `Rules/REVIEW_CHECKLIST.md` - 代码审查
- `Rules/SECURITY.md` - 安全基线

#### 产品与设计
- `Skills/product-northstar/SKILL.md` - 产品定位
- `Skills/user-scenarios/SKILL.md` - 用户场景
- `Skills/ia-navigation/SKILL.md` - 信息架构
- `Skills/ui-pattern-library/SKILL.md` - UI 组件库
- `Docs/01_Product/Placeholder_Features.md` - 功能清单

#### 技术架构
- `Skills/database-schema/SKILL.md` - 数据库设计
- `Skills/ai-interaction/SKILL.md` - AI 集成
- `Docs/03_Decisions/ADR-*.md` - 所有架构决策

#### 功能规范
- `Skills/atomization/SKILL.md` - 自动拆分
- `Skills/tags/SKILL.md` - 标签系统
- `Skills/clean-defiller/SKILL.md` - 文本清理
- `Skills/speech-transcription/SKILL.md` - 语音转写
- `Skills/capture-ui/SKILL.md` - 记录界面
- `Skills/timeline-browse/SKILL.md` - 时间线
- `Skills/search/SKILL.md` - 搜索功能
- `Skills/review-memory/SKILL.md` - 回顾系统
- `Skills/project-review/SKILL.md` - 项目回顾

#### 开发工具
- `Skills/devtools-debug-suite/SKILL.md` - 调试套件
- `Skills/privacy-redaction-standard/SKILL.md` - 隐私脱敏
- `Skills/dev-logging-system/SKILL.md` - 日志系统
- `Skills/feature-flags-governance/SKILL.md` - 特性开关

#### 工作历史
- `Docs/04_Sessions/*.md` - 工作会话日志（46 个）
- `Docs/05_Changes/*.md` - 变更日志（48 个）
- `THREADING_FIX_FINAL.md` - 详情页卡死修复
- `COMPLIANCE_FIX_SUMMARY.md` - 合规性修复
- `FREEZE_DIAGNOSIS.md` - 输入卡死诊断

---

## 开发工作流程

### 标准开发流程（必须遵守）

详见 **`Rules/WORKFLOW.md`**，核心步骤：

1. **任务接收**
   - 阅读任务描述
   - 定位相关 Skill（从 `Skills/SKILLS_INDEX.md` 开始）
   - 阅读 Skill 的完整定义和验收标准

2. **规划阶段**（复杂任务）
   - 使用 `Rules/PLAN_TEMPLATE.md` 创建计划
   - 识别影响的文件和模块
   - 定义验证步骤

3. **实现阶段**
   - 严格按照 Skill 的规范实现
   - 遵守 `Rules/AI_RULES.md` 的编码规范
   - 使用 TDD 方法（见 `Rules/TDD_GUIDE.md`）

4. **文档阶段**（必须）
   - 创建 Session Log：`Docs/04_Sessions/YYYY-MM-DD_session-NNN.md`
   - 创建 Change Log：`Docs/05_Changes/Change-NNN-description.md`
   - 必要时创建 ADR：`Docs/03_Decisions/ADR-NNN-title.md`

5. **验证阶段**
   - 运行自动化测试
   - 执行手动测试（见 `MANUAL_TEST_CHECKLIST.md`）
   - 代码审查（见 `Rules/REVIEW_CHECKLIST.md`）

6. **交接阶段**
   - 更新 Session Log 的 Handover Notes
   - 标记任务状态
   - 提交代码

### 文档规范（必须遵守）

详见 **`Rules/DEV_LOG_RULES.md`**，核心要求：

#### Session Log（工作会话日志）
- **文件位置**: `Docs/04_Sessions/YYYY-MM-DD_session-NNN.md`
- **模板**: `Templates/SESSION_LOG_TEMPLATE.md`
- **必须包含**:
  - Goal（目标）
  - Plan（计划）
  - Work Log（工作日志，按时间记录）
  - Decisions（决策）
  - Changes（变更引用）
  - Verification（验证）
  - Next Steps（下一步）
  - Handover Notes（交接说明）

#### Change Log（变更日志）
- **文件位置**: `Docs/05_Changes/Change-NNN-description.md`
- **模板**: `Templates/CHANGELOG_TEMPLATE.md`
- **必须包含**:
  - Summary（摘要）
  - Motivation（动机）
  - Files Changed（修改文件列表，包含行号）
  - Verification Steps（验证步骤）
  - Rollback Notes（回滚说明）

#### ADR（架构决策记录）
- **文件位置**: `Docs/03_Decisions/ADR-NNN-title.md`
- **模板**: `Templates/ADR_TEMPLATE.md`
- **何时创建**: 重大架构决策、技术选型、设计模式选择
- **必须包含**:
  - Status（状态）
  - Context（背景）
  - Decision（决策）
  - Consequences（后果）
  - Alternatives Considered（备选方案）

### 代码审查清单

详见 **`Rules/REVIEW_CHECKLIST.md`**，关键检查项：

#### 功能完整性
- [ ] 是否完全实现 Skill 的验收标准？
- [ ] 是否处理所有边界情况？
- [ ] 是否有错误处理？

#### 代码质量
- [ ] 是否遵守 Swift 代码风格？
- [ ] 是否有清晰的命名？
- [ ] 是否有必要的注释？
- [ ] 是否避免重复代码？

#### 测试覆盖
- [ ] 是否有单元测试？
- [ ] 是否有 UI 测试（如需要）？
- [ ] 是否通过手动测试？

#### 文档完整性
- [ ] 是否创建 Session Log？
- [ ] 是否创建 Change Log？
- [ ] 是否更新相关文档？

#### 安全与隐私
- [ ] 是否遵守隐私脱敏规范？
- [ ] 是否避免硬编码敏感信息？
- [ ] 是否正确处理用户数据？

---

## 当前状态与待办事项

### 项目当前状态

#### 已完成功能（生产可用）
- ✅ 文字/语音记录输入
- ✅ AI 自动清理文本
- ✅ AI 自动拆分（Atomization）
- ✅ 智能标签建议
- ✅ 记录详情查看
- ✅ 时间线浏览
- ✅ 搜索功能（标签、内容）
- ✅ 项目管理
- ✅ 回顾功能（每日、每周、每月）
- ✅ 开发者工具（AI Debug、Core Data 查看）
- ✅ 隐私脱敏（P0/P1/P2 数据保护）

#### 已知问题（已修复）
- ✅ 详情页打开时卡死 - 已修复（`THREADING_FIX_FINAL.md`）
- ✅ 隐私数据泄露风险 - 已修复（`COMPLIANCE_FIX_SUMMARY.md`）
- ✅ 输入超时问题 - 已修复（10 秒超时保护）

#### 占位功能（UI 存在，功能未实现）
详见 **`Docs/01_Product/Placeholder_Features.md`**

- ⚠️ 语音转写（界面存在，转写逻辑未完全实现）
- ⚠️ 辅助归档卡片（部分功能未完成）
- ⚠️ 部分回顾页面（数据未完全关联）

### 立即待办事项（P0）

#### 1. 测试最新修复
- [ ] 删除应用并重新安装
- [ ] 测试详情页打开是否流畅
- [ ] 验证 UI 不卡死
- [ ] 检查控制台无错误
- **参考**: `THREADING_FIX_FINAL.md` 测试部分

#### 2. 完成手动测试
- [ ] 执行 `MANUAL_TEST_CHECKLIST.md` 中的所有测试
- [ ] 记录测试结果
- [ ] 修复发现的问题

#### 3. 隐私脱敏验证
- [ ] 在 DevTools 中查看 AI Debug 日志
- [ ] 验证 API keys 已脱敏（`sk-***REDACTED***`）
- [ ] 验证 Bearer tokens 已脱敏
- [ ] 验证邮箱已脱敏（`***@***.***`）
- **参考**: `COMPLIANCE_FIX_SUMMARY.md` 测试部分

### 短期待办事项（P1）

#### 1. 实现"查看来源"功能
- **背景**: 数据层已准备好（startChar/endChar），需要实现 UI
- **文件**: `Life Narattor/Views/CaptureDetailSheet.swift`
- **任务**:
  - 在 Atom 详情中添加"查看来源"按钮
  - 高亮显示原文中的对应部分
- **参考**: `Skills/atomization/SKILL.md` 中的源文本追溯部分

#### 2. 添加单元测试
- **目标**: 提高代码覆盖率
- **优先测试**:
  - `AIDebugRedactor.redact()` - 隐私脱敏逻辑
  - `AtomTagStore.markAsKey()` - 标记为重点功能
  - `AtomTagStore.deleteAtom()` - 删除 Atom 级联逻辑
- **参考**: `Rules/TDD_GUIDE.md`

#### 3. 完善语音转写
- **当前状态**: 占位实现
- **待办**:
  - 实现真实的语音转写调用
  - 完善错误处理
  - 测试离线场景
- **参考**: `Skills/speech-transcription/SKILL.md`

#### 4. 补充中文示例到 AI Prompts
- **背景**: 审计建议增加中文示例
- **文件**: `Life Narattor/AI/AIService.swift`
- **任务**: 在 prompt 中添加中文示例

### 长期待办事项（P2）

#### 1. 改进 Fallback Atomization
- **目标**: 当 AI 不可用时，提供更智能的本地拆分
- **建议**: 添加情感检测、行动检测

#### 2. 软删除功能
- **目标**: 可恢复的删除操作
- **方案**: 添加 `deletedAt` 字段

#### 3. 指标收集
- **目标**: 跟踪拆分质量、脱敏效果
- **实现**: 在 `LogStore` 中添加指标

#### 4. 完善占位功能
- **参考**: `Docs/01_Product/Placeholder_Features.md`
- 逐步实现所有占位功能

### 技术债务

1. **ADR-001 缺失**: 需要完善隐私脱敏架构决策文档
2. **测试覆盖率低**: 核心功能缺少单元测试
3. **文档滞后**: 部分 Skills 需要更新（AI Prompts 中文化）

---

## 常见问题解答

### Q1: 如何快速理解项目？
**A**: 按照"快速上手路径"阅读 30 分钟即可开始工作：
1. `README.md` + `Rules/AI_RULES.md`
2. `Skills/product-northstar/SKILL.md`
3. `Skills/database-schema/SKILL.md` + `Skills/ai-interaction/SKILL.md`
4. `THREADING_FIX_FINAL.md`

### Q2: 如何开始第一个任务？
**A**: 遵循标准工作流程：
1. 阅读任务描述，找到对应的 Skill
2. 阅读 Skill 的完整定义和验收标准
3. 查看相关代码文件
4. 创建 Session Log（`Docs/04_Sessions/`）
5. 实现功能
6. 创建 Change Log（`Docs/05_Changes/`）
7. 测试并交接

### Q3: 必须创建文档吗？
**A**: 是的，必须遵守 `Rules/DEV_LOG_RULES.md`：
- **Session Log** - 每个工作会话都必须创建
- **Change Log** - 每次代码修改都必须创建
- **ADR** - 重大架构决策必须创建

### Q4: 如何理解数据模型？
**A**: 阅读顺序：
1. `Skills/database-schema/SKILL.md` - 完整数据库设计
2. `Docs/03_Decisions/ADR-001-coredata-v1.md` - Core Data 架构
3. `Life Narattor/Data/*Entity.swift` - 实体定义代码
4. `Life Narattor/Data/PersistenceController.swift` - 配置代码

### Q5: 如何理解 AI 集成？
**A**: 阅读顺序：
1. `Skills/ai-interaction/SKILL.md` - AI 架构概览
2. `Skills/atomization/SKILL.md` - 拆分功能
3. `Skills/tags/SKILL.md` - 标签建议
4. `Life Narattor/AI/AIService.swift` - AI 服务代码
5. `Life Narattor/Data/AtomizationCoordinator.swift` - 协调器代码

### Q6: 如何调试？
**A**: 使用 DevTools：
1. 运行应用（Cmd+R）
2. 导航到 DevTools（根据 `Skills/devtools-debug-suite/SKILL.md`）
3. 查看 **AI Debug** 日志 - AI 请求/响应
4. 查看 **Core Data** - 数据库内容
5. 导出诊断文件 - 完整日志

### Q7: 如果构建失败怎么办？
**A**: 检查清单：
1. Clean Build Folder（Cmd+Shift+K）
2. 删除 DerivedData：`~/Library/Developer/Xcode/DerivedData`
3. 重新打开 Xcode
4. 检查 Core Data 模型是否匹配实体定义
5. 查看最近的 Change Log 的 Rollback Notes

### Q8: 如何回滚变更？
**A**:
1. 找到对应的 Change Log（`Docs/05_Changes/Change-NNN-*.md`）
2. 阅读 **Rollback Notes** 部分
3. 按照说明执行回滚操作
4. 或者使用 Git：`git revert <commit-hash>`

### Q9: 最新修复了什么？
**A**:
- **详情页卡死** - `THREADING_FIX_FINAL.md`
  - 问题：`@MainActor` 阻塞主线程
  - 修复：线程模型重构
  - 状态：已修复，待测试

- **隐私合规** - `COMPLIANCE_FIX_SUMMARY.md`
  - 7 个合规问题修复
  - 隐私脱敏增强
  - 状态：已修复，待测试

### Q10: 有哪些已知问题？
**A**:
- ✅ 详情页卡死 - 已修复
- ✅ 隐私泄露 - 已修复
- ⚠️ 语音转写 - 部分功能占位
- ⚠️ 测试覆盖率低 - 待改进

### Q11: 如何贡献代码？
**A**:
1. 遵守 `Rules/AI_RULES.md`
2. 严格按照 Skill 实现
3. 创建完整文档（Session Log + Change Log）
4. 通过代码审查（`Rules/REVIEW_CHECKLIST.md`）
5. 提交前运行测试

### Q12: 如何查看开发历史？
**A**:
- **会话日志**: `Docs/04_Sessions/*.md`（按日期排序）
- **变更日志**: `Docs/05_Changes/*.md`（按编号排序）
- **架构决策**: `Docs/03_Decisions/ADR-*.md`
- **Git 历史**: `git log`

### Q13: Skills 是什么？
**A**: Skills 是功能规范文档，每个 Skill 包含：
- **目标** - 功能目的
- **UI 设计** - 界面规范
- **数据模型** - 数据结构
- **业务逻辑** - 实现逻辑
- **验收标准** - 完成定义
- **示例** - 代码示例

**所有实现必须严格遵守 Skill！**

### Q14: 如何处理 AI 调用超时？
**A**:
- 已实现 10 秒超时保护（`CaptureFeedViewModel.swift`）
- 超时后会自动降级到 Fallback
- 查看 `FREEZE_DIAGNOSIS.md` 了解详情

### Q15: 如何测试隐私脱敏？
**A**:
1. 配置真实 API Key（开发环境）
2. 触发 AI 调用（创建记录）
3. 打开 DevTools → AI Debug
4. 验证日志中的 API Key 显示为 `sk-***REDACTED***`
5. 参考 `MANUAL_TEST_CHECKLIST.md` 第 6 项

---

## 附录

### A. 关键术语表

| 术语 | 含义 |
|------|------|
| **Capture** | 记录，用户输入的原始内容（文字或语音） |
| **Atom** | 拆分后的语义单元（事件、感受、思考、行动、决定、洞察、问题、上下文） |
| **Clean Text** | 清理后的文本（去除口语化，保留语义） |
| **Raw Text** | 原始文本（用户输入的原文） |
| **Tag** | 标签（项目、主题、人物、目标） |
| **Atomization** | 拆分，将一条记录分解为多个 Atoms |
| **Quick Ack** | 快速确认，AI 对记录的确认反馈 |
| **Assist Archive** | 辅助归档，AI 生成的总结卡片 |
| **Source Traceability** | 源文本追溯，Atom 在原文中的位置（startChar/endChar） |
| **Privacy Redaction** | 隐私脱敏，敏感数据的掩码处理 |
| **DevTools** | 开发者工具，用于调试和诊断 |
| **Fallback** | 降级，AI 不可用时的本地处理 |
| **Session Log** | 工作会话日志，记录开发过程 |
| **Change Log** | 变更日志，记录代码修改 |
| **ADR** | Architecture Decision Record，架构决策记录 |
| **Skill** | 功能规范文档 |

### B. 文件命名规范

- **Session Log**: `YYYY-MM-DD_session-NNN.md`
  - 例如：`2026-03-06_session-001.md`

- **Change Log**: `Change-NNN-short-description.md`
  - 例如：`Change-048-ai-atomization-debug.md`

- **ADR**: `ADR-NNN-title.md`
  - 例如：`ADR-001-coredata-v1.md`

### C. 联系方式

- **项目仓库**: （Git 地址）
- **文档位置**: `Life Narattor/Docs/`
- **问题跟踪**: （Issue Tracker 地址）
- **代码审查**: （PR 流程）

### D. 版本历史

- **v1.0** (2026-03-06) - 初始版本，包含完整项目概览和阅读指南

---

## 总结

### 最重要的 5 件事

1. **阅读 `Rules/AI_RULES.md`** - 所有开发的基础规则
2. **理解产品定位** - 阅读 `Skills/product-northstar/SKILL.md`
3. **理解数据模型** - 阅读 `Skills/database-schema/SKILL.md`
4. **理解 AI 集成** - 阅读 `Skills/ai-interaction/SKILL.md` 和 `Skills/atomization/SKILL.md`
5. **遵守文档规范** - 每次工作创建 Session Log 和 Change Log

### 立即行动

1. ✅ 按照"快速上手路径"阅读 30 分钟
2. ✅ 打开 Xcode，运行项目
3. ✅ 阅读 `THREADING_FIX_FINAL.md`，了解最新修复
4. ✅ 测试应用，熟悉功能
5. ✅ 开始第一个任务

### 需要帮助？

如有任何问题：
1. 先查看本文档的"常见问题解答"
2. 搜索 `Docs/04_Sessions/` 和 `Docs/05_Changes/` 寻找相关案例
3. 查阅对应的 Skill 文档
4. 联系项目团队

---

**欢迎加入 Life Narrator 项目！祝你开发顺利！** 🎉

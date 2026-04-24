---
date: 2026-03-16
owner: Codex
status: accepted
---

# ADR-011: RetrievalPlan 统一检索计划模型

## Context
Life Narrator 后续要支持长周期回顾与叙事生成，例如：
- “我过去一个月都干了什么”
- “这个项目过去一个月做了什么”
- “岗位切换之后，我的情绪有没有明显变化”
- “最近胃口不好，和工作压力有没有关系”

这类需求在表面上差异很大，但底层都需要同一条主链：
1. 理解用户提问意图
2. 生成检索计划
3. 召回记录
4. 压缩成 AI 可读材料
5. 生成回顾或叙事

此前讨论里曾将用户需求分为 `overview` 与 `focused` 两类。继续沿着这个方向实现时，最大的风险是把两类需求做成两套独立系统，造成：
- 逻辑重复
- 策略漂移
- 维护成本提高
- 不利于统一调试与评估

同时，标签系统已经进入“宽录入、后提取”的方向：
- 显性标签由用户控制
- 隐性标签和 `tag_hints` 主要服务召回
- 高质量答案依赖提取层的过滤、排序和压缩，而不是录入层过早限制

## Decision
采用统一的 `RetrievalPlan` 模型，覆盖 `overview` 与 `focused` 两种查询形态。

### 1. 不做两套系统
不建立：
- 一套 overview 引擎
- 一套 focused 引擎

统一实现为：
- 一套检索与压缩流水线
- 两种不同的参数配置和排序策略

### 2. `overview` / `focused` 只是查询形态，不是系统档位
统一 `RetrievalPlan.mode`：
- `overview`
- `focused`

两者的区别只体现在：
- 过滤强度
- 排序权重
- 压缩策略
- 输出预期

### 3. RetrievalPlan 的 canonical 结构
第一版设计为：
- `mode`
- `time_range`
- `primary_filters`
- `secondary_filters`
- `tag_scope_weights`
- `ranking_weights`
- `compression_policy`
- `question_shape`

解释如下：

#### mode
- `overview`: 弱约束、重覆盖、重变化与代表性
- `focused`: 强约束、重相关性、重证据密度

#### time_range
时间范围，例如：
- 最近 7 天
- 最近 30 天
- 某次事件前后 14 天

#### primary_filters
强过滤条件，例如：
- 某项目标签
- 某目标标签
- 某人物标签
- 某场景标签
- 关键时间边界

#### secondary_filters
扩展过滤或相关线索，例如：
- 同组主题标签
- 相关 habit/context/person 标签
- 与主过滤标签语义相近的隐性标签

#### tag_scope_weights
按标签组给权重，例如：
- `project`
- `habit`
- `theme`
- `person`
- `goal`
- `context`

#### ranking_weights
召回排序权重，例如：
- 主题相关性
- 新出现程度
- 重复频率
- 结果/状态变化强度
- 时间代表性
- 转折性

#### compression_policy
压缩召回结果的策略，例如：
- 每周最多取 1 条代表记录
- 每个高频主题最多取 2 条代表记录
- 优先 earliest/latest/turning point
- focused 模式下允许保留更高证据密度

#### question_shape
提问形态，例如：
- 开放回顾
- 项目回顾
- 主题回顾
- 模式回顾
- 对比查询
- 关联查询

### 4. Overview 的默认职责
当用户提出模糊问题，例如：
- “我过去一个月都干了什么”
- “我最近有什么变化”

系统默认进入 `overview` 模式。

这类回答不追求一次命中用户真实意图，而是输出第一层地图：
- 主要行动变化
- 新出现的主题或人物
- 明显的状态变化
- 几个关键节点
- 可继续追问的方向

### 5. Focused 的默认职责
当用户提出具体问题，例如：
- “岗位切换之后，我情绪有没有明显变化”
- “最近胃口不好，和工作压力有没有关系”
- “这个项目过去一个月做了什么”

系统默认进入 `focused` 模式。

这类回答应更强调：
- 强过滤
- 时间前后对比
- 更严格的标签组合
- 更高的证据密度

### 6. 标签进入检索层的原则
标签系统遵循：
- 录入层尽量宽
- 提取层再严格筛

因此：
- 隐性标签与 `tag_hints` 可以广泛进入长期索引链
- 但在 `RetrievalPlan` 中，最终是否参与召回和叙事，要由过滤、排序和压缩规则决定
- 不要求在录入阶段先判断“是否值得进入长期链”

### 7. 不预置大量默认隐性标签文本
不采用“先塞大量默认隐性标签词”的方案。

改为预置：
- 常见用户回顾需求模板
- 模板到标签组权重的映射
- 模板到排序/压缩策略的映射

这样可避免：
- 标签污染
- 语义过泛
- 后续召回噪声过高

## Consequences

### Positive
- 统一 overview / focused 的实现路径，降低系统分叉风险。
- 标签系统和长周期叙事系统能自然对接。
- 允许录入层保持高召回，而将质量控制放在提取层。
- 更适合后续加入：
  - 主题回顾
  - 第二自我模拟
  - 季度整合 Job

### Negative
- 第一版需要额外设计检索计划字段和压缩策略，不是“直接把记录喂给 AI”。
- 若没有好的排序与压缩，wide recall 仍可能产生叙事噪音。
- 需要后续补充评测样本，验证 overview / focused 在不同用户问题下的表现差异。

## Implementation Notes
第一阶段只做设计约束，不立即改 UI 和生成逻辑。

后续实现顺序建议：
1. 定义 `RetrievalPlan` Swift 模型
2. 实现意图分型：overview / focused + question_shape
3. 实现 `RetrievalPlanBuilder`
4. 为回顾/叙事生成准备中间材料格式
5. 在周/月/主题/项目回顾中逐步接入

## Non-Goals
当前 ADR 不包含：
- 最终 narrative prompt 文案
- 具体压缩算法实现
- 第二自我高权重记忆层的打分策略
- 标签数据库迁移

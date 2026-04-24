---
name: ai-interaction
description: Defines dual AI interaction modes for Life Narrator: QuickAck (5–10s acceptable, confirm-and-stitch) and DeepTask (long review for projects/themes/time ranges). Includes API shapes, event types, and storage mapping.
metadata:
  product: life-narrator
  version: "0.2"
  updated: "2026-03-08"
  changelog: "v0.2 新增：分层 Atomization 流水线契约、ModelProvider 抽象层规范、中国模型接入预留、成本分级策略"
---

# AI Interaction: QuickAck vs DeepTask

## Mode A — QuickAck (confirm + light stitch)
### Purpose
After a capture, return a small confirmation that:
- the system understood what was recorded,
- optionally stitches with 1–2 other items from today.

### Timing
- 5–10 seconds acceptable
- Can be single-shot (no streaming required)

### Output rules
- 1–2 sentences; or 1 title + 1 detail line.
- No advice; no abstraction; no “report voice”.
- Prefer user’s words.

### Recommended UI placement
- Inline under capture card as a “确认条”, not an assistant bubble.

### API (suggested)
`POST /v1/quick/ack`
Input:
- capture_id
- clean_text (or raw_text if clean not ready)
- today_highlights (optional: top 2 atom snippets)
- persona_profile=stable_warm
Output:
- ack_title, ack_detail

## Mode B — DeepTask (serious review)
### Purpose
Generate structured review outputs with more compute:
- Daily serious review (optional)
- Weekly / Monthly review
- Project review
- Theme review
- “What would I think/do about X?” (friend reply *after* narrative)

### Timing
- 10–60s+ acceptable
- Must support progress + result retrieval (streaming preferred)

### API (suggested)
`POST /v1/tasks`
- task_type: project_review | weekly_review | theme_review | deep_daily_review
- inputs: scope + time_range + tags
- output_spec: blocks + styles

`GET /v1/tasks/{id}/stream` (SSE)
`GET /v1/tasks/{id}/result`

### Output structure
- self_narrative_text (layer 1)
- ai_comments {gentle/honest/action/pattern} (layer 2)
- structure_blocks (timeline/turning_points/blockers/next_steps) optional
- narrative_sources for traceability

## Storage mapping
- QuickAck: store in captures as `ack_title/ack_detail` (or a small `ack` table)
- DeepTask: store in narratives + ai_comments + narrative_sources

## Acceptance criteria
- QuickAck never makes the app feel like a chatbot.
- DeepTask outputs are clearly “review artifacts” (narratives), not chat.
- Both modes preserve raw and trace sources.

## Interaction modes (V1)

### 1) QuickAck (Log mode)
- Purpose: confirm the record is captured + optional light stitch.
- Timing: 5–10s acceptable.
- Output: ack_title + optional ack_detail.
- No long responses.

### 2) Assist (Archive-first, <=3 turns)
- Purpose: handle small questions and turn answers into a durable Archive Card.
- Total turns <= 3; only one clarification question.
- Output must follow `assist-archive-card` template (Reply + Archive Card).
- If user needs deep exploration: recommend external AI, then import transcript for archiving.

### 3) DeepTask (Review)
- Purpose: daily/weekly/project/theme review; may take longer.
- Output: self narrative + optional structure blocks + optional multi-style comments.

## API contract — Assist

### Request (example)
```json
{
  "mode": "assist",
  "capture_id": "cap_123",
  "payload": {
    "question_text": "fine / fan / find 总是分不清，帮我整理一下练习点",
    "imported_transcript_text": null
  },
  "constraints": { "max_turns": 3, "allow_clarification": true },
  "persona_profile": "stable_warm"
}
```

### Response (example)
```json
{
  "reply": "我明白了，你想把 fine / fan / find 的区别讲清楚并变成可练习的记录。",
  "archive_card": {
    "title": "fine / fan / find 发音区分",
    "context": "用户经常混淆这三者的发音。",
    "key_points": [
      "fan 是 /æ/（像 cat 的元音）",
      "fine 是 /aɪ/（有明显滑音）",
      "find 是 /aɪ/ + 词尾 /d/"
    ],
    "next_steps": ["做 3 分钟最小对比练习：fan–fine–find"],
    "tag_suggestions": [{"tag_type":"theme","name":"English pronunciation"}],
    "confidence": "medium"
  },
  "turn_policy": {"used_clarification": false, "turns_remaining": 1}
}
```

## Turn limiting policy (enforcement)

- Client and server should both enforce:
  - max_turns = 3
  - max_clarification_questions = 1
- After the Archive Card is delivered, the assistant should present closure UI:
  - Save / Edit / End (no “keep chatting” affordance).
- If user continues: respond with a short closure and suggest external AI for deep talk, then import transcript for archiving.

---

## 分层 Atomization 流水线（v0.2 新增）

### 设计背景

标准 Atomization 流程将「领域分类」和「精细解析」合并为单次重模型调用，导致：
- 注入全量标签库（随增长可达数百标签），token 浪费
- 大模型在大量标签噪声中工作，Atom 质量下降

分层流水线将两个任务拆开，按难度匹配不同模型。

### 两步流水线契约

#### Step 1：领域分类（轻量，< 1s）

```
输入：
  - capture_text: 用户原始输入
  - domain_taxonomy: 本地 tag-taxonomy.json（见 tags skill）
  - existing_user_tags: 用户已有显性标签列表（简短）

输出：
  - matched_domains: string[]   // 命中的 domain key，1–3 个
  - rough_tags: string[]        // 粗粒度标签建议，2–5 个
  - skip_step2: boolean         // true 表示内容极简，可直接归档

约束：
  - 模型：轻量级（GPT-4o-mini / Claude Haiku / DeepSeek V3）
  - 最大输入 token：600
  - 超时：3s，超时则 skip_step2=false，跳至 Step 2 使用默认领域
```

#### Step 2：精细 Atomization（重模型，2–4s）

```
输入：
  - capture_text: 原始输入
  - filtered_tags: 由 Step 1 matched_domains 筛选出的标签子集
  - atomization_policy: 来自 atomization skill 的策略参数

输出：
  - atoms[]: { type, content, start_char, end_char }
  - hidden_tags[]: { tag, dimension, confidence, is_primary }
  - visible_tag_suggestion: 最多 1 个显性标签建议

约束：
  - 模型：重模型（GPT-4o / Claude Sonnet / Qwen-Plus）
  - 最大输入 token：1200（含 filtered_tags，通常 ~60 个）
  - 超时：10s
```

#### pass-through 规则（跳过 Step 1）

满足以下任一条件，直接进入 Step 2 并使用默认领域：
- Capture 长度 < 20 字（过短，分类意义不大）
- 用户已手动指定项目标签（显性标签提供了充分上下文）
- 离线模式（Step 1 需要网络，Step 2 可离线）

---

## ModelProvider 抽象层（v0.2 新增）

### 设计原则

模型选择必须可配置，不得硬编码 OpenAI。所有 AI 调用必须通过 `ModelProvider` 协议路由。

### 协议定义（概念性）

```swift
protocol ModelProvider {
    var name: String { get }
    var lightModel: ModelConfig { get }   // 用于 Step 1、ContradictionDetector
    var heavyModel: ModelConfig { get }   // 用于 Step 2、DeepTask、自我模型 Job
    func complete(request: AIRequest) async throws -> AIResponse
}

struct ModelConfig {
    let modelId: String
    let maxInputTokens: Int
    let costPerMillionInputTokens: Double   // USD
    let supportsStreaming: Bool
    let dataRegion: DataRegion              // .us / .cn / .eu
}

enum DataRegion {
    case us     // OpenAI、Anthropic
    case cn     // DeepSeek、Qwen（数据路由至中国服务器）
    case eu     // 欧盟合规区域
}
```

### 内置 Provider 规划

| Provider | 阶段 | lightModel | heavyModel | 数据区域 |
|---------|-----|-----------|-----------|---------|
| OpenAIProvider | V1（默认）| GPT-4o-mini | GPT-4o | us |
| DeepSeekProvider | V1.5（经济模式）| DeepSeek V3 | DeepSeek V3 | cn |
| QwenProvider | V1.5（备选）| Qwen-Turbo | Qwen-Plus | cn |
| AnthropicProvider | 预留 | Claude Haiku | Claude Sonnet | us |

### 数据区域警告要求

当用户切换至 `dataRegion=.cn` 的 Provider 时，**必须**弹出一次性知情确认：

```
⚠️ 隐私提示
经济模式使用的 AI 服务会将您的记录发送至中国服务器处理。
Life Narrator 中的内容包含您的个人经历和想法，请确认您了解并接受这一数据路由。

[我了解，继续使用]  [保持默认模式]
```

用户确认后记录 `userAcknowledgedCNDataRegion=true`，之后不再重复提示。

### FeatureFlag 保护

```swift
// 分层流水线开关（灰度验证用）
FeatureFlags.useLayeredAtomization: Bool = false  // V1 默认关闭

// 经济模式开关
FeatureFlags.enableEconomyProvider: Bool = false  // V1.5 开放
```

---

## 成本分级策略参考

| 配置 | 月成本（20条/天）| 适用场景 |
|-----|---------------|---------|
| 单步 GPT-4o（当前）| ~$4.86 | 质量优先，无成本顾虑 |
| 分层 mini+4o | ~$3.86 | 默认推荐，质量接近，成本-20% |
| 全 DeepSeek V3 | ~$0.34 | 经济模式，用户知情选择 |

> 注：以上为估算值，实际费用取决于标签库规模、Atom 输出长度和缓存命中率。

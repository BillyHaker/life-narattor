---
name: tags
description: Explicit & hidden tags, suggestions, tag manager, merge rules. Use this skill when specifying, implementing, or validating the Life Narrator iOS app feature set in this area. Follow the UI + behavior requirements exactly, and keep changes consistent with the North Star principles.
metadata:
  product: life-narrator
  version: "0.2"
  owner: product
  updated: "2026-03-08"
  changelog: "v0.2 新增：隐性标签置信度规范、主辅标签区分、六维语义框架、领域分类树、分层标签流水线"
---

# Tags

## Purpose
Explicit & hidden tags, suggestions, tag manager, merge rules.

## Scope
### In scope
- Explicit & hidden tags, suggestions, tag manager, merge rules.

### Out of scope
- Anything not listed above; if uncertain, default to the V1 boundaries in `product-northstar`.

## Definitions
- **Capture**: a single user input (text or voice) stored as Raw + Clean.
- **Raw**: original text/transcript, preserved verbatim.
- **Clean**: de-filled text (remove fillers/pauses/repeats), *not* formalized.
- **Atom**: smallest structured unit extracted from a Capture (event/feeling/action/etc.).
- **Narrative**: rendered story output (daily/weekly/project) built from Atoms.
- **AI Comment**: second-layer “friend reply” separated from self narrative.

## UI Requirements
### Screens & entry points
**Primary entry points**
- **Project tab → top-right `管理标签`** → Tag Manager.
- **Capture expansion → Atoms tab** → `+` pill or `添加标签…` opens Tag Picker.
- **Project detail**: shows the project tag in header; tapping it opens Tag Picker.

**Secondary entry points**
- **Search / filters**: selecting a tag filters results.
- **Atom Detail**: Tag section includes add/remove.

### Components
**Tag Manager (二级界面)**
- Segmented control: `项目 | 主题 | 人物 | 目标`
- List rows (per tag):
  - Icon + color chip (optional)
  - Tag name
  - Usage count (optional, V1 can omit)
  - `…` menu
- Top CTA: `+ 新建标签`

**Tag Picker (底部抽屉/Sheet)**
- Search field (filters within current tag type)
- “Recent / 常用” section (top 6)
- Full list
- `+ 新建` inline row (creates and auto-selects)

**Tag pills (in Atom rows)**
- Visible tags only.
- AI-suggested tag pill is visually subdued and marked `建议` until user taps to confirm.

### Interactions
**Create**
- From Tag Manager: tap `+ 新建标签` → enter name (optional icon/color) → saved.
- From Tag Picker: search; if not found tap `创建 “X”` → saved + selected.

**Assign / remove**
- Tap `+` in Atom row → opens Tag Picker for a default tag type (priority: project → theme → person → goal).
- Tap existing pill → remove (with undo toast) or open edit (choice depends on your UX style; recommend: tap to open picker with that tag preselected).

**Rename**
- Tag Manager `…` → `重命名`.
- Renaming updates `tags.name` only; keeps `id` stable.

**Merge** (V1 recommended)
- Tag Manager `…` → `合并到…` → choose destination tag.
- Merge behavior:
  - Repoint all `atom_tags` and `capture_tags` from source tag → destination tag.
  - Update any `threads.primary_tag_id` pointing to source.
  - Soft-delete source tag (or mark `is_user_visible=0` + `deleted_at`).
- Must show confirmation: `将 “A” 合并到 “B”？该操作会影响历史记录。`

**Delete**
- Tag Manager `…` → `删除`.
- Delete is **soft-delete**; removes from pickers but does not erase history records.

**Set as common / recent**
- Tag Manager `…` → `设为常用`.
- Common tags appear at top of Tag Picker.

### States
**Empty states**
- No tags in a category: show short explanation + CTA `新建一个`.

**Errors**
- Creating duplicate: show `已存在同名标签` and focus input.
- Merge failure (db constraint): show retry + log.

## Data & Storage
- Persist to local database per `database-schema`.
- All derived outputs must be versioned (ruleset_version/style_version) and traceable to sources.

## AI Inputs/Outputs
### AI tag suggestion (V1)
AI may suggest **at most 1** visible tag per capture by default (project preferred), shown as `建议` until user confirms.

**Input**
```json
{
  "capture_id": "cap_...",
  "atoms": [
    {"type":"event","content":"..."},
    {"type":"feeling","content":"..."}
  ],
  "existing_visible_tags": {
    "project": ["AI Proposal","Life Narrator"],
    "theme": ["焦虑","效率"],
    "person": [],
    "goal": []
  },
  "policy": {
    "max_visible_suggestions": 1,
    "prefer_project": true
  }
}
```

**Output**
```json
{
  "suggestions": [
    {"tag_type":"project","name":"AI Proposal","score":0.62}
  ]
}
```

### Hidden tags (optional / backend-only)
- Hidden tags may be stored for search and aggregation but must not be shown to user in V1.
- If stored, set `tags.is_user_visible=0` and `tag_type="hidden"`.

---

## 隐性标签质量控制规范（v0.2 新增）

### 两类标签的定位

| 类型 | 来源 | 用户可见 | 主要用途 |
|-----|-----|---------|---------|
| 显性标签 | 用户从项目界面创建 | ✅ | 用户主动分类、项目归属 |
| 隐性标签 | AI 分析时自动生成 | ❌（不在 V1 UI 中显示）| 自我模型更新、语义检索、主题回顾 |

**隐性标签是整个分析体系的主要标签来源**，显性标签是用户意图的显式表达，两者互补。

---

### 置信度分数规范

每条隐性标签必须附带置信度分数（0.0–1.0），不同场景使用不同阈值：

| 使用场景 | 最低阈值 | 说明 |
|---------|---------|-----|
| 自我模型更新 Job | ≥ 0.65 | 只有高置信标签才能触发自我模型分析 |
| 叙事生成（Narrative）| ≥ 0.80 | 叙事需要准确的语义聚合 |
| 主题回顾检索 | ≥ 0.65 | 允许相对宽松，增加召回 |
| 探索性检索 | ≥ 0.40 | 发现意外关联，允许低置信 |

**置信度输出格式**：
```json
{
  "tag": "运动",
  "dimension": "behavioral",
  "confidence": 0.87,
  "is_primary": true
}
```

---

### 主辅标签区分

每次 Atomization 输出的隐性标签分为两级：

- **主标签（primary）**：最能代表该 Atom 语义的 1–3 个标签，置信度通常 ≥ 0.7
- **辅助标签（secondary）**：补充语境的标签，置信度可低至 0.4

检索时默认使用主标签；自我模型 Job 只使用主标签；探索模式可包含辅助标签。

---

### 六维语义框架

隐性标签按六个语义维度组织，作为 Prompt 提示而非硬性约束：

| 维度 | key | 示例标签 |
|-----|-----|---------|
| 领域 | `domain` | 运动、工作、学习、健康、人际 |
| 情绪 | `emotion` | 焦虑、满足、疲惫、兴奋 |
| 行为 | `behavioral` | 坚持、回避、计划、执行 |
| 对象 | `subject` | 晨跑、睡眠、代码、家人 |
| 方法论 | `methodology` | 番茄钟、复盘、系统思考 |
| 主题 | `theme` | 长期主义、自我认知、效率 |

AI 应尽量覆盖多个维度，但不强制每条 Atom 都有六维标签；与其强行覆盖，不如少而精确。

---

### 防止标签滥用的约束

1. **无数量硬上限**，但 AI 必须对每个标签给出置信度，不得随意打低置信标签。
2. **现有标签优先**：如有相似度 ≥ 0.85 的现有标签，复用而非新建。
3. **禁止过度细化**：避免「周二晨跑」这类过于具体的标签；应抽象为「晨跑」+「behavioral」维度。
4. **标签去重**：同一条 Atom 内，同维度不超过 2 个主标签。

---

### 领域分类树（Tag Taxonomy）

用于分层流水线的 Step 1 领域筛选，打包于 app 本地（`tag-taxonomy.json`）：

```json
{
  "taxonomy_version": "1.0",
  "domains": [
    {
      "key": "health",
      "label": "健康",
      "sub_tags": ["运动", "睡眠", "饮食", "心理健康", "医疗"]
    },
    {
      "key": "work",
      "label": "工作",
      "sub_tags": ["项目", "会议", "代码", "设计", "效率", "压力"]
    },
    {
      "key": "learning",
      "label": "学习",
      "sub_tags": ["阅读", "课程", "语言", "技能", "思考"]
    },
    {
      "key": "relationships",
      "label": "人际",
      "sub_tags": ["家人", "朋友", "同事", "社交"]
    },
    {
      "key": "self",
      "label": "自我",
      "sub_tags": ["情绪", "价值观", "目标", "习惯", "自我认知"]
    },
    {
      "key": "life",
      "label": "生活",
      "sub_tags": ["日常", "消费", "旅行", "娱乐"]
    }
  ]
}
```

领域树随用户标签库增长定期更新（用户标签可归入对应 domain）。

## Edge cases
- **Same name across categories**: allowed (e.g., project “健身” vs theme “健身”) but picker must scope by category.
- **Tag rename conflicts**: if renaming to existing name in same category, block.
- **Merge cycles**: prevent merging a tag into itself.
- **Deleting a tag used by threads**: thread should either rebind to null or ask user to select replacement.
- **AI suggestion mismatch**: user can dismiss suggestion; store dismissal (optional) to reduce repeats.

## Acceptance criteria
- User can create/rename/merge/delete visible tags via Tag Manager.
- User can assign/remove tags from atoms via Tag Picker.
- AI suggestions never auto-apply; user must confirm.
- Tag operations preserve history and do not break project views.
- 每条隐性标签附带置信度分数（0.0–1.0），写入数据库。
- 自我模型更新 Job 只取 confidence ≥ 0.65 的标签。
- 现有相似标签优先复用，新建标签须有明确语义区分。
- `tag-taxonomy.json` 打包于 app bundle，Step 1 领域分类从本地读取，不发起网络请求。

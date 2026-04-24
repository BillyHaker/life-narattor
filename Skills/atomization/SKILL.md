---
name: atomization
description: Atomization types, extraction, editing UI, source mapping. Use this skill when specifying, implementing, or validating the Life Narrator iOS app feature set in this area. Follow the UI + behavior requirements exactly, and keep changes consistent with the North Star principles.
metadata:
  product: life-narrator
  version: "0.1"
  owner: product
---

# Atomization

## Purpose
Atomization types, extraction, editing UI, source mapping.

## Scope
### In scope
- Atomization types, extraction, editing UI, source mapping.

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
Atomization is primarily *revealed* (not forced) via the Capture expansion UI.

**Primary entry points**
- **Record tab → Capture Feed**: Tap a Capture card → expansion sheet/panel opens.
  - Default sub-tab: **Clean** (整理后).
  - Atomization appears as:
    - An inline status line: `已拆成 X 条 ▾` (shown once atomize completes)
    - A third sub-tab: **Atoms** (拆分)
- **Timeline tab → Day detail**: In `Sources / 引用来源` section, user can tap a source Capture → opens same Capture expansion, Atom tab available.
- **Project tab → Project detail → Timeline**: Atom rows shown in project timeline list. Tapping an atom opens **Atom Detail** (read-only + edit type/tag).

**Secondary entry points**
- **Search results**: tapping a result opens either Atom Detail (if atom-level hit) or Capture expansion (if capture-level hit).

### Components
**Capture expansion (modal sheet / right panel)**
- Header: capture timestamp + optional quick actions (Copy, Delete)
- Segmented control tabs:
  - `整理后` (Clean)
  - `原始` (Raw)
  - `拆分` (Atoms)

**Atoms tab (拆分)**
- Atom list (ordered by `order_in_capture`)
  - Left: type icon + label
  - Middle: atom content (1–3 lines, expandable)
  - Right: `…` menu
- Inline tag pills row per atom (user-visible tags only)
  - `+` pill opens tag picker (projects/themes/people/goals)
- 来源链接（Source Highlight）：当 Atom 存在有效的 `start_char / end_char` 偏移时，**必须**在 atom row 尾部显示一个”来源”按钮；点击后在整理后（Clean）文本中高亮对应片段。若偏移数据缺失（老数据或 AI 未返回偏移），静默隐藏此按钮，不报错。

**Atom Detail (sheet)**
- Type selector (chips): Event / Feeling / Thought / Action / Decision / Insight / Question / Context
- Content text (editable)
- Tags section (visible tags)
- Traceability section:
  - Parent Capture timestamp
  - Raw/Clean snippet
  - “Open parent capture” button

### Interactions
**Viewing**
- After atomize completes, the Capture card shows `已拆成 X 条 ▾`. Tap opens expansion and lands on **Atoms tab**.
- Atoms tab supports:
  - Tap atom row → open Atom Detail
  - Tap tag pill → filter suggestions / edit tag

**Editing atoms (V1)**
- Users may:
  1) **Edit content** of an atom (minor wording fixes; preserves “self voice”)
  2) **Change type** (reclassify)
  3) **Add/remove visible tags**
- Users may *optionally*:
  - Merge two atoms (v1 optional): multi-select → “合并” → creates a new atom, retains links to sources
  - Split one atom (v1 optional): “拆分” on Atom Detail → user selects text ranges → creates two atoms

**What editing must NOT do**
- Must not rewrite into formal prose automatically.
- Must not delete Raw/Transcript.
- Must not silently re-run clean/atomize and overwrite without versioning.

**Menus (`…`)**
- `改类型…`
- `添加标签…`
- `标记为关键` (adds a hidden tag or flag, used later in narratives)
- `复制`
- `删除此条` (soft-delete atom only)

### States
**Loading / partial**
- If atomize job pending: show status line `正在拆分…` and Atoms tab shows skeleton rows.
- If clean exists but atomize failed: show `拆分失败 · 重试` CTA.

**Empty**
- If atomize returns 0 atoms (rare): show `没有可拆分的信息` and keep Clean/Raw tabs available.

**Error**
- If AI returns invalid JSON: store failure in `ai_jobs.last_error`, UI shows `拆分失败` with `重试`.
- Retry must be idempotent: new `atoms` written with new `ruleset_version` / `atomize_version` if applicable.

## Data & Storage
- Persist to local database per `database-schema`.
- All derived outputs must be versioned (ruleset_version/style_version) and traceable to sources.

## AI Inputs/Outputs
### When to trigger
- Trigger atomize after **Clean** is available.
- Trigger on-demand when user opens Atoms tab if not computed yet.

### Input contract (to AI backend)
```json
{
  "capture_id": "cap_...",
  "clean_text": "...",
  "language": "zh",
  "policy": {
    "keep_user_voice": true,
    "no_formalization": true,
    "max_atoms": 8,
    "prefer_atomic_meaning_units": true
  },
  "existing_visible_tags": [
    {"tag_type":"project","name":"AI Proposal"}
  ]
}
```

### Output contract
```json
{
  "atoms": [
    {
      "type": "event",
      "content": "刚开完会。",
      "confidence": 0.82,
      "start_char": 0,
      "end_char": 5
    },
    {
      "type": "feeling",
      "content": "我有点烦。",
      "confidence": 0.76
    }
  ],
  "atomize_version": "atom_v1"
}
```

### Mapping rules
- Atom content must preserve user’s lexicon (e.g., keep “有点/感觉/好像”).
- Prefer 2–5 atoms; only exceed if user content clearly contains multiple distinct units.
- `type` must be one of the enumerated types.
- If offsets are provided, they must map to `clean_text`.

## Edge cases
- **Very short capture**: “吃饭” → single `event` atom.
- **Mixed content**: “开会很烦，明天要梳理” → `event + feeling + action`.
- **Ambiguous type**: default to `thought` unless explicit emotion (`feeling`) or explicit action (`action`).
- **Profanity / strong emotion**: keep wording; do not sanitize unless user requests.
- **Duplicated atoms** on retry: dedupe by `(capture_id, order_in_capture, content)` or by replacing all atoms for capture when `atomize_version` changes.
- **User edits clean text** (if allowed later): must invalidate atoms and regenerate with a new version.

## Acceptance criteria
- 对任意已处理的 Capture，用户可查看 Raw、Clean 和 Atoms 三个视图，不丢失可追溯性。
- Atom 列表保留用户原词汇和语气，无正式化改写。
- 用户可修改 Atom 类型和标签，变更在本地持久化。
- 失败状态展示可操作的重试入口；重试不破坏已有数据。
- Atoms 可按天和按项目标签查询（通过关联查询）。
- **来源可追溯**：对拥有有效 `start_char / end_char` 的 Atom，用户可通过"来源"按钮在 Clean 文本中定位并高亮原始片段；无偏移数据的 Atom 静默隐藏此入口，不影响其他功能。

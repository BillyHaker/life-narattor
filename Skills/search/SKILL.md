---
name: search
description: Search UX and query behaviors; keyword + tag filters; optional vector stub. Use this skill when specifying, implementing, or validating the Life Narrator iOS app feature set in this area. Follow the UI + behavior requirements exactly, and keep changes consistent with the North Star principles.
metadata:
  product: life-narrator
  version: "0.1"
  owner: product
---

# Search

## Purpose
Search UX and query behaviors; keyword + tag filters; optional vector stub.

## Scope
### In scope
- Search UX and query behaviors; keyword + tag filters; optional vector stub.

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
- Global search icon (top-right) OR dedicated Search screen (can live under Review tab in V1).

**Secondary entry points**
- Tap a tag pill anywhere → opens filtered search.
- From Review “memory snippets” → opens search.

### Components
**Search home**
- Search bar with placeholder: `搜一搜：比如“上次什么时候也觉得方向乱？”`
- Recent searches
- Quick filters (pills): `项目` `主题` `人物` `日期范围`

**Results list**
- Grouped by date (default)
- Each result card:
  - Time
  - Snippet (prefer Clean/Atom content)
  - Tag pills
  - Tap opens Atom Detail or Day detail

**Smart result banner (optional)**
- If query matches a recurring phrase: `我找到了 3 次类似记录` with quick jump links.

### Interactions
**Query types supported (V1)**
- Keyword search across:
  - `clean_texts.clean_text`
  - `atoms.content`
  - tag names
- Tag filter combinations (project/theme/person/goal)
- Date range filter

**Natural language queries (V1-lite)**
- If user enters a full question, do not attempt full LLM reasoning by default.
- Heuristic: extract key terms and run keyword search.
- Provide optional `用 AI 帮我找` button (Deep) for semantic search later.

**Open results**
- Atom result → Atom Detail
- Capture result → Capture expansion
- Day jump → Timeline Day detail

### States
**Empty**
- `没找到相关记录` + tips: “试试换个关键词/选择标签/扩大时间范围”。

**Loading**
- Local search should be instant; show minimal spinner for large datasets.

**Error**
- If DB unavailable, show `搜索不可用`.

## Data & Storage
- Persist to local database per `database-schema`.
- All derived outputs must be versioned (ruleset_version/style_version) and traceable to sources.

## AI Inputs/Outputs
V1 does not require AI for search.

Optional AI enhancement (future / deep mode):
- User taps `用 AI 帮我找` → create Deep task that performs semantic retrieval and returns top matches with explanations.

## Edge cases
- Very common words → cap results, encourage filters.
- Mixed languages → simple tokenization; keep as-is.
- Privacy: do not send search queries to AI unless user explicitly taps AI search.

## Acceptance criteria
- User can find past records via keywords + tags + date filters.
- Results open into the correct detail screens.
- Works offline.

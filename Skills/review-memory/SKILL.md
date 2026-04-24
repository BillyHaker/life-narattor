---
name: review-memory
description: Review tab: weekly/monthly review, memory snippets, second brain feel. Use this skill when specifying, implementing, or validating the Life Narrator iOS app feature set in this area. Follow the UI + behavior requirements exactly, and keep changes consistent with the North Star principles.
metadata:
  product: life-narrator
  version: "0.1"
  owner: product
---

# Review Memory

## Purpose
Review tab: weekly/monthly review, memory snippets, second brain feel.

## Scope
### In scope
- Review tab: weekly/monthly review, memory snippets, second brain feel.

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
- Bottom tab: **Review (回顾)**.

**Secondary entry points**
- From Timeline: `本周/本月` range switch.
- From Search: `查看相关回顾`.

### Components
**Review home**
- Top CTAs:
  - `本周回顾`
  - `本月回顾`
  - `按项目回顾`
  - `按主题回顾` (optional V1; can reuse tag category “theme”)
- Memory snippets (lightweight, not dashboard):
  - `你最近常提到：A、B、C` (from visible tags or keywords)
  - `最近的节奏：更稳定/更忙/更散` (only if confident; otherwise omit)
  - `最近的几个关键节点` (optional)

**Weekly/Monthly review detail**
- Section A: `自我叙事` (stitched, first-person)
- Section B: `AI回应` (style pills)
- Section C: `本周/本月片段` (clickable highlights linking to days or atoms)

### Interactions
**Generate review**
- Tap `本周回顾` or `本月回顾`:
  - If review exists: open it.
  - If not: create Deep task (recommended) and stream content.

**Memory snippet taps**
- Tap a tag/keyword snippet → navigates to filtered timeline/search.

**“It remembers” moments**
- When the user asks a question like “我上次什么时候也觉得方向乱？” and lands here via Search, show a small banner:
  - `我找到了 3 次类似记录` with links.

### States
**Empty**
- If no data in period: show `这段时间还没有记录`.

**Partial**
- If narrative exists but comments missing for a style, show `该风格评论尚未生成` + `生成`.

**Error**
- Show `生成失败 · 重试`.

## Data & Storage
- Persist to local database per `database-schema`.
- All derived outputs must be versioned (ruleset_version/style_version) and traceable to sources.

## AI Inputs/Outputs
Review generation uses Deep mode.

### Input contract
```json
{
  "task_type": "period_review",
  "period": {"type":"weekly","key":"2026-W09","from":"2026-02-23","to":"2026-03-01"},
  "atoms": [ {"id":"a1","ts":...,"type":"event","text":"..."} ],
  "visible_tags": {"project":["..."],"theme":["..."]},
  "policy": {
    "self_voice": "keep_user_voice",
    "no_formalization": true,
    "max_chars": 2400
  }
}
```

### Output
- `self_narrative_text` + `comments{style}` + `highlights[]` + `sources[]`.

## Edge cases
- User has very sparse week: output should be brief; avoid overinterpretation.
- Mixed languages: keep phrases; don’t translate by default.
- Over-analysis risk: if confidence low, omit pattern statements.

## Acceptance criteria
- Review tab provides a calm, “second brain” feel without turning into analytics.
- Weekly/monthly reviews read like self reflection.
- Reviews can link back to specific sources.

## Include Assist Archive Cards in Review

- Review surfaces (weekly/monthly/project/theme) should include saved **Archive Cards** as primary items.
- Prefer showing the Archive Card over raw transcripts.
- Provide a small “Source” affordance to open the original capture/transcript for traceability.

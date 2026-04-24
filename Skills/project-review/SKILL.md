---
name: project-review
description: Project threads, project detail UI, deep project review outputs. Use this skill when specifying, implementing, or validating the Life Narrator iOS app feature set in this area. Follow the UI + behavior requirements exactly, and keep changes consistent with the North Star principles.
metadata:
  product: life-narrator
  version: "0.1"
  owner: product
---

# Project Review

## Purpose
Project threads, project detail UI, deep project review outputs.

## Scope
### In scope
- Project threads, project detail UI, deep project review outputs.

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
- **Project tab → Project detail → `回顾`**
  - CTA: `生成项目回顾` / `更新回顾`

**Secondary entry points**
- From Review tab: `按项目回顾` → select project.
- From a capture/atom: project tag pill → project detail.

### Components
**Project detail header**
- Project name
- Optional short description
- Last updated timestamp
- Project tag pill

**Sub-tabs** (V1 minimum)
- `时间线` (atoms/captures filtered by project tag)
- `回顾` (project narrative)

**Project review page (`回顾`)**
- Section A: `项目叙事` (self narrative)
- Section B: `AI回应` (style switcher)
- Section C: `结构块` (read-only blocks)
  - `时间轴` (key dates)
  - `转折点` (turning points)
  - `卡点` (blockers)
  - `下一步` (next steps)
- Section D: `引用来源` (optional)

### Interactions
**Generate / update**
- Tap `生成项目回顾`:
  - Creates a Deep task (recommended) so backend can take longer.
  - UI shows progress state (spinner + short text: `在整理这个项目…`).
  - As partial text streams in, show it in `项目叙事` section.

**Style switching**
- Style pills under `AI回应`: `🌿 温和` `🔍 直白` `🎯 行动` `🪞 模式`
- Switching style **does not** regenerate self narrative; only regenerates/loads the comment for that style.

**Open sources**
- Tap a timeline item/turning point → opens source Atom Detail.

**Edit** (V1 optional)
- Allow editing self narrative text only (not structure blocks) with `编辑叙事`.
- Saving creates a new narrative version (or overwrites; versioning preferred).

### States
**Empty**
- If project has no tagged items: show `这个项目还没有记录` and CTA `去记录`.

**Loading**
- Show incremental content while generating.

**Error**
- If generation fails: `生成失败 · 重试`.
- If comment generation fails for a style: show placeholder under that style only.

## Data & Storage
- Persist to local database per `database-schema`.
- All derived outputs must be versioned (ruleset_version/style_version) and traceable to sources.

## AI Inputs/Outputs
### Trigger
- Deep mode task when user taps `生成项目回顾` or `更新回顾`.

### Input contract
```json
{
  "task_type": "project_review",
  "project": {"tag_id": "tag_proj_...", "name": "AI Proposal"},
  "time_range": {"from": "2026-02-01", "to": "2026-03-02"},
  "atoms": [
    {"id":"a1","ts":1772,"type":"event","text":"...","tags":["project:AI Proposal"]}
  ],
  "policy": {
    "self_voice": "keep_user_voice",
    "no_formalization": true,
    "max_chars": 2400,
    "include_structure_blocks": true
  }
}
```

### Output contract
```json
{
  "self_narrative_text": "...第一人称、轻连接、像自己回顾...",
  "structure_blocks": {
    "timeline": [{"date":"2026-02-18","summary":"..."}],
    "turning_points": [{"date":"2026-02-25","summary":"..."}],
    "blockers": ["..."],
    "next_steps": ["..."]
  },
  "comments": {
    "gentle": "...",
    "honest": "...",
    "action": "...",
    "pattern": "..."
  },
  "sources": [{"source_type":"atom","source_id":"a1","quote_snippet":"..."}],
  "style_version": "project_self_v1"
}
```

## Edge cases
- Project spans long time: cap sources; prefer key turning points.
- Sparse data: narrative should be short and honest; avoid filling in.
- Conflicting tags: if an atom belongs to multiple projects, include only if user-visible project tag matches.
- User has edited atoms: always use latest atom content.

## Acceptance criteria
- User can generate a project review that reads like self-reflection (not a report).
- Comments are separated and style-switchable.
- Review links back to sources.
- Works even if AI fails (user can still browse project timeline).

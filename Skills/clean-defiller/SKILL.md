---
name: clean-defiller
description: Defines the “Clean” transformation: remove fillers/pauses/repeats and repair broken fragments WITHOUT formalizing or upgrading vocabulary. Use this skill to implement or evaluate the Clean pipeline and UI presentation.
metadata:
  product: life-narrator
  version: "0.1"
---

# Clean De-filler (Not Formalize)

## Core intent
Clean is **noise removal**, not rewriting.
It exists to:
- make storage readable,
- make atomization easier,
- preserve the user’s original voice.

## Inputs
- Raw text (typed) OR raw transcript (from voice)
- Optional transcript segments with timestamps

## Output contract
Return:
- `clean_text` (string)
- `removed_fillers` (list; for explainability/debug)
- `ruleset_version` (e.g., clean_v1)
- Optional `diff_json` (token-level removals)

## Allowed operations (✅)
1) Remove fillers / hesitation tokens:
- “嗯 / 呃 / 额 / 啊 / 就是 / 那个 / 然后(连续堆叠时) / 你知道吗 / 嗯哼 …”
2) Remove stutters & immediate repeats:
- “我我我觉得” → “我觉得”
- “有点有点乱” → “有点乱”
3) Repair obvious fragment breaks caused by pauses:
- “今天那个会…有点乱…没抓到重点” → “今天那个会有点乱，没抓到重点。”
4) Light punctuation insertion for readability:
- Add commas/periods where the user paused, without changing wording.

## Forbidden operations (❌)
- Do NOT upgrade vocabulary or formalize:
  - ❌ “有点乱” → “较为混乱”
  - ❌ “我很烦” → “我感到困扰”
- Do NOT add new facts, interpretations, or “summary”
- Do NOT change sentiment intensity (keep “有点/可能/感觉/好像/其实”)
- Do NOT reorganize paragraphs into “report style”

## Preserve list (must keep unless clearly filler)
Keep hedges because they are voice markers:
- 有点 / 可能 / 感觉 / 好像 / 其实 / 我觉得 / 我在想

## Examples
Raw:
- “嗯…刚开完会…方向有点乱…就是没抓到重点…明天再梳理一下”
Clean:
- “刚开完会，方向有点乱，没抓到重点，明天再梳理一下。”

Raw:
- “我觉得我觉得今天挺累的”
Clean:
- “我觉得今天挺累的。”

## UI requirements
- Default show Clean in feed once ready.
- In capture details, always allow switching between Raw and Clean.
- Never label Clean as “润色/改写”; label as “已去停顿/已去口头噪音”.

## Acceptance criteria
- Users report the Clean text “still sounds like me”.
- Clean never introduces formal vocabulary not present in raw.
- Raw is always preserved and accessible.

---
name: timeline-browse
description: Timeline browsing views, day cards, navigation into narratives. Use this skill when specifying, implementing, or validating the Life Narrator iOS app feature set in this area. Follow the UI + behavior requirements exactly, and keep changes consistent with the North Star principles.
metadata:
  product: life-narrator
  version: "0.1"
  owner: product
---

# Timeline Browse

## Purpose
Timeline browsing views, day cards, navigation into narratives.

## Scope
### In scope
- Timeline browsing views, day cards, navigation into narratives.

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
- Bottom tab: **Timeline (时间线)**.

**Secondary entry points**
- From **Review tab**: tap `今天/本周/本月` → navigates to Timeline scoped views.
- From **Search results**: jump into a specific date in timeline.

### Components
**Timeline home**
- Top scope switcher: `今天 | 本周 | 本月 | 自定义`
- Date list (cards) in reverse chronological order.
  - Each date card shows:
    - Date header (e.g., `3月1日 · 周六`)
    - 3–6 highlight lines (from atoms; preserves user voice)
    - CTA: `查看日记` (if narrative exists) or `生成日记` (if not)

**Day detail**
- Sections:
  1) `今日叙事` (self narrative + comment)
  2) `今日记录` (captures grouped by time of day)
  3) `引用来源` (optional: mapping narrative sentences back to sources)

### Interactions
**Open day**
- Tap date card → Day detail.

**Generate narrative**
- If narrative missing: Day card shows `生成日记`.
- Tap triggers:
  - Quick mode: if few captures (fast render)
  - Deep mode: if many captures or user chooses `认真整理`

**Browse without AI**
- Even if AI fails, user can still open Day detail and see raw capture feed for that day.

**Highlight line selection**
- Tap a highlight line → opens Atom Detail (if atom hit) or Capture expansion.

### States
**Empty**
- No records in time range: show `这段时间还没有记录` + CTA `去记录`.

**Loading**
- Pull-to-refresh triggers local reload; if synced later, also refresh remote.

**Error**
- If narrative generation fails: show inline error with retry.

## Data & Storage
- Persist to local database per `database-schema`.
- All derived outputs must be versioned (ruleset_version/style_version) and traceable to sources.

## AI Inputs/Outputs
Timeline itself can be rendered from local DB. AI is only used for:
- Generating daily narrative (see `daily-narrative-two-layer`)
- Creating short highlights for day cards (optional)

**Optional highlight generation contract**
Input: list of atoms; output: 3–6 short lines, user-voice preserved.

## Edge cases
- Very busy day: cap highlights to 6; show `更多…`.
- Timezone changes: day boundaries use stored capture timezone; display using user settings timezone.
- Duplicate captures at same timestamp: stable ordering by `created_at` then `id`.

## Acceptance criteria
- Users can browse by date range without needing AI.
- Day cards show meaningful highlights and allow navigation to details.
- Day detail always shows captures; narrative is additive.

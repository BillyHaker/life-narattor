---
name: daily-narrative-two-layer
description: Implements the Daily Narrative experience with strict two-layer separation: (1) self narrative in the user’s voice, (2) optional AI friend comment with selectable styles. Use this skill for Timeline Day Detail and nightly review flows.
metadata:
  product: life-narrator
  version: "0.1"
---

# Daily Narrative Two-Layer

## Output structure (non-negotiable)
### Layer 1: Self Narrative (用户自我叙事)
- First person (“我…”)
- Built primarily by stitching user atoms (not “writing an essay”)
- Light connectors only (当时/后来/现在看/其实/好像)
- No abstract “summary/report language”

### Layer 2: AI Comment (朋友式回应)
- Separate section visually and in storage
- Optional and style-switchable
- 1–2 sentences default
- “Mirror + light insight”, not “coach advice”
- Can be honest/straight, but never insulting

## Night reminder (only one per day)
- At user-configured time (default 21:30)
- CTA: “生成今天的日记”
- If user ignores, no repeated nagging

## DayDetailScreen (Lo-fi)
Header:
- “YYYY/MM/DD · 周X”

Section A: 📖 今日叙事
- Displays self narrative text
- Buttons:
  - “编辑叙事” (edits only layer 1)
  - “重新生成” (re-render self narrative)

Section B: 💬 AI 的回应
- Style pills:
  - 🌿 温和观察 (gentle)
  - 🔍 诚实直说 (honest)
  - 🎯 行动提醒 (action)
  - 🪞 模式识别 (pattern; may require more history)
- “关闭回应” toggle
- “收藏这条回应” (optional)

Section C: 引用来源（可折叠）
- List snippets with timestamps: “来自 9:12 …”

## Comment styles (constraints)
### gentle
- Warm, steady, non-judgmental
- Uses hedges: 听你这么说/感觉/好像
- Example: “听下来你其实已经在想下一步怎么理清了，这点挺稳的。”

### honest
- Direct but kind; points out gaps/patterns
- Avoid “你应该”
- Example: “你提到‘方向乱’不止一次，可能你还缺一个更固定的收敛方式。”

### action
- One small actionable nudge, phrased softly
- Example: “下次再觉得乱的时候，也许先写下3个必须回答的问题会更快收敛。”

### pattern
- Summarize a repeated pattern across days
- Must cite at least 2 occurrences internally; keep phrasing tentative
- Example: “最近几次你先烦一下，然后就会转向整理结构。”

## Acceptance criteria
- Users feel Layer 1 is “me talking to myself”.
- Users can switch comment styles without regenerating Layer 1.
- Comment never appears inside the self narrative block.

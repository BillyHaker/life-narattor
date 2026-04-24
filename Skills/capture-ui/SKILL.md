---
name: capture-ui
description: Specifies the iOS Record/Capture experience: bottom input bar, feed layout, capture expansion, QuickAck confirmation bar, and tag/atom editing flows. Use this skill when implementing Record tab UI and its related sheets.
metadata:
  product: life-narrator
  version: "0.1"
---

# Capture UI

## Goal
Make recording frictionless while preserving future structure:
- User can drop fragments anytime.
- System confirms it “got it” without turning the app into a chatbot.
- Structure is optional and progressive (expand-on-demand).

## RecordFeedScreen (Lo-fi)
Top:
- Date title: “今天 · YYYY/MM/DD”
- Optional small subtitle: “随手记一句就好”

Body:
- Grouped by day-part (optional V1): 上午 / 下午 / 晚上
- Each Capture rendered as a **Capture Card** (not chat bubbles)

Bottom:
- **Fixed Input Bar**
  - Left: mic button (press & hold)
  - Center: multiline text field (auto-grow)
  - Right: send button
  - Placeholder: “记录当下发生的事或想法…”

## Capture Card layout
Primary text:
- Default show **Clean text** if available
- If clean not ready yet: show raw/transcript with a subtle “整理中…”

Secondary rows (below text):
1) **QuickAck bar** (first-level confirmation; 5–10s OK)
2) **Processing status** (if still running)
3) **Expand toggle** (only when atoms exist): “已拆成 3 条 ▾”

### QuickAck bar (must NOT look like assistant chat)
- Shown as light gray inline pill/line beneath the capture
- 1–2 lines max
- Examples:
  - “✅ 已记下：开会 + 很烦”
  - “· 今天看起来是：吃饭 → 运动”
- TTL: optionally auto-fade after 20s; but keep accessible via expand if desired.

## Capture expand (CaptureDetailSheet)
Trigger:
- Tap “已拆成 X 条 ▾” OR long-press capture → “查看详情”

Sheet structure:
- Tabs: **整理后** | **原始** | **拆分**
  - 整理后: Clean text
  - 原始: Raw transcript/text
  - 拆分: Atom list (editable)

### Atom list row
- Left: type icon + type label (事件/感受/行动/决定/想法/洞察/问题)
- Main: atom content (single line, expandable)
- Right: “…” menu:
  - Change type
  - Add tag
  - Mark as key
  - Delete atom (soft)

### Tag pills
- Under each atom row show explicit tag pills (project/theme/person/goal)
- AI suggestion pill style:
  - lighter, with “建议” label
  - tap to confirm (writes to DB as source=ai confirmed_by_user)

## Tag selection UX (AddTagSheet)
- Show “常用标签” first (user settings)
- Then recent projects
- Then search/create new

## Audio UX
- Press & hold mic to record; release to send.
- Immediately create Capture with audio_path.
- Show “转写中…” status; allow playback even if transcription fails.

## Acceptance criteria
- User can create a capture in ≤ 2 seconds from opening the app.
- QuickAck appears within 5–10s and never dominates the feed.
- User can always access Raw text/audio even after Clean/Atoms exist.

## Intent routing: Log (default) vs Assist

- Default intent is **Log** (pure record). The input bar must default to Log on every new app launch.
- Provide a lightweight toggle near the input bar: **Log** / **Assist**.
- Log mode:
  - After send: show Clean text + inline QuickAck confirmation bar.
  - No chatbot bubbles.
- Assist mode:
  - After send: show a compact **Reply** (1–2 lines) + **Archive Card** per `assist-archive-card` skill.
  - Must include actions: Save as Record / Edit Card / End.
- If the user pastes a long external transcript, suggest switching to Assist mode and render as an Archive Card.

## UI changes: Inline QuickAck vs Assist Card

### Inline QuickAck (Log mode)
- Presentation: subtle inline status/ack bar under the capture card.
- Content: 1 line title + optional 1 line stitch (“today you also logged …”).
- Never present as assistant chat messages.

### Assist Card (Assist mode)
- Presentation: card under the capture item (not a full chat thread).
- Sections:
  1) Reply (1–2 sentences)
  2) Archive Card fields (editable)
- Buttons:
  - Primary: Save as Record
  - Secondary: Edit
  - Tertiary: End

## States

- Log mode states: pending_clean -> clean_ready -> atoms_ready -> tags_suggested.
- Assist mode states: analyzing -> reply_ready -> archive_card_ready -> saved.
- If assist takes >10s: show “正在整理…” with spinner; allow user to leave screen without losing state.

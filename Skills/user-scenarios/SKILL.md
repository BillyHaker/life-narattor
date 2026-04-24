---
name: user-scenarios
description: Scenario playbooks for Life Narrator V1. Use this skill to validate flows, UI requirements, and AI outputs across different user behaviors (daytime fragments vs schedule-only + nightly reflection, project review, second-brain recall).
metadata:
  product: life-narrator
  version: "0.1"
---

# User Scenarios (Playbooks)

## Scenario 1 — Daytime fragments (high frequency)
1. User opens Record tab and types: “刚开完会，感觉很烦。”
2. App creates Capture immediately and shows it in feed.
3. Within 5–10s, QuickAck appears under the card:
   - “✅ 已记下：开会 + 很烦”
4. User expands → sees Clean/Raw/Atoms tabs.
5. At night reminder, user opens Day Detail:
   - Layer 1 self narrative stitches atoms
   - Layer 2 comment (gentle) appears; user can switch to honest

Success signal: user feels “this is me talking to myself”.

## Scenario 2 — Schedule-only daytime + nightly reflection
Day:
- User records short schedule items only: “9点开会”、“12点吃饭”、“下午运动”。

Night:
1. Tap “生成今天的日记”
2. System renders Layer 1: sequence with light connectors.
3. Optional single prompt (non-nagging): “要不要补一句今天的感受？”
4. User adds: “开会有点乱，我有点慌。”
5. Narrative updates; comment appears.

Success: user can keep daytime minimal but still get meaningful nightly review.

## Scenario 3 — Project review (deep)
1. User opens Projects → AI Proposal → Review tab.
2. Tap “生成项目回顾” (DeepTask).
3. Progress UI shows “在整理…”
4. Result:
   - Layer 1: project self narrative
   - Layer 2: style-switchable comments
   - Optional blocks: turning points / blockers / next steps

Success: reads like user’s own retrospective, not a report.

## Scenario 4 — Second brain recall (“it remembers”)
1. User searches: “我上次什么时候也觉得方向乱？”
2. Results show dates/snippets (not a long chat).
3. User opens one day → sees self narrative + sources.

Success: trust increases because the app can cite past moments.

## Scenario: Assist (simple question -> archive card -> save)

### Context
User has a small question and wants it saved as a reviewable note.

### Steps
1) User switches input intent to **Assist** and asks:
   - “fine / fan / find 我总说不清，帮我整理一下并记录。”
2) System shows “正在整理…”
3) Assistant returns:
   - Reply (1–2 lines)
   - Archive Card (title, key points, next steps)
4) User taps **Save as Record**
5) System stores:
   - Raw input
   - Archive Card as artifact/narrative
   - Atoms from key points & next steps
6) Quick verification:
   - Search “fine fan find” returns the archived card.

## Scenario: Assist with 1 clarification (turn limit)

1) User (Assist): “我最近总觉得很乱，怎么办？”
2) Assistant asks **one** clarifying question:
   - “你说的‘乱’更像是工作项目还是生活节奏？”
3) User answers: “主要是工作项目。”
4) Assistant outputs Reply + Archive Card and ends. No further questions.

## Scenario: External deep chat import -> archive

### Context
User had a long conversation in another AI tool. They paste/share it into Life Narrator for archiving.

### Steps
1) User taps Import -> Paste transcript.
2) System suggests switching to Assist-Import mode.
3) Assistant reads transcript and outputs an Archive Card:
   - What I asked
   - Answer summary (<=5 bullets)
   - Next steps (<=3 bullets)
   - Tag suggestions
4) User saves as record; raw transcript remains attached for traceability.

## Scenario: User tries to continue chatting (polite closure)

After delivering the Archive Card, user asks another follow-up.
Assistant responds:
- one short sentence acknowledging,
- suggests using external AI for deep discussion,
- offers: “把你那边的对话贴过来，我可以帮你整理归档。”
No extended chat thread is created.

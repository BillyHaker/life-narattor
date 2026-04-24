---
name: product-northstar
description: Defines Life Narrator V1 product intent, non-negotiable principles, terminology, and scope boundaries. Use this skill whenever making product decisions, writing prompts, or implementing features to ensure the app stays a record-and-review “self-mirror” (not a chatbot, coach, or knowledge base).
metadata:
  product: life-narrator
  version: "0.1"
  tone: stable-warm
---

# Product North Star

## 1) What this product is
**Life Narrator** is a *record-and-review* tool that turns fragmented life inputs (text/voice) into:
- **Cleaned records** (de-filler, not formalized)
- **Structured atoms** (event/feeling/action/decision/insight…)
- **Narratives** for review (daily / weekly / project)

It aims to feel like **“a steadier, warmer self living in your phone”**: remembers more, helps you organize, and offers *optional* friend-like reflection **after** your self narrative.

## 2) What this product is NOT
- Not a productivity/GT D task manager
- Not a knowledge-base “second brain” (documents/PKM)
- Not a therapy app or psychological intervention
- Not a multi-turn chatbot that constantly asks questions
- Not an AI writing app that rewrites users into formal prose

## 3) Non-negotiable principles (decision benchmark)
### P1. Record first, always
- Never block recording with mandatory forms, labels, or prompts.
- One night reminder max; no frequent proactive questioning.

### P2. Narrative ownership belongs to the user
- “Self narrative” must read like the user talking to themselves.
- AI must not replace user wording, elevate tone, or write “summary reports”.

### P3. Two-layer output, always separated
- Layer 1: **Self narrative** (user voice)
- Layer 2: **AI comment** (friend reply) — optional + style-switchable
Never mix them.

### P4. Clean means de-filler, not formalize
- Remove pauses/fillers/repetition/broken fragments.
- Do **not** upgrade vocabulary, do **not** rewrite into formal style.

### P5. Stable-warm personality (B)
- Warm, steady, low-drama, non-judgmental.
- Avoid “coach” tone and overconfident analysis.
- Prefer hedges: “感觉/好像/听下来…”.

### P6. Trust comes from traceable memory
- Every derived output must be traceable to raw captures/atoms.
- Preserve raw forever; show sources when needed (“来自 9:12”).

## 4) V1 scope boundaries
### In scope
- iOS app
- Capture: text + voice (with transcription)
- Clean de-filler
- Atomization + light tag suggestion
- Explicit tags: Projects (must), Themes/People/Goals (nice-to-have)
- Daily narrative + optional AI comment styles
- Project view + project narrative
- Review tab: weekly/monthly review + light “memory snippets”
- Search: keyword + tag filters (vector search optional stub)

### Out of scope (V1)
- Cloud sync / multi-device / collaboration
- Complex analytics dashboards
- High-frequency proactive check-ins
- Mental-health interventions
- Arbitrary “assistant” conversations unrelated to records

## 5) Core terms
- **Capture**: one user input.
- **Raw**: original transcript/text, preserved.
- **Clean**: de-filled text for easier structure.
- **Atom**: structured unit extracted from a capture.
- **Thread**: grouping lens (project/theme/person/goal).
- **Narrative**: rendered review text.
- **AI Comment**: second-layer friend reply.
- **QuickAck**: quick confirmation line(s) after capture.
- **DeepTask**: longer “review” job (project/week/theme).

## 6) Tone constraints (global)
- Prefer 1st person in self narrative.
- AI comment: 1–2 sentences by default; can be stricter with “honest” style but never insulting.
- Never use “总体而言/本质上/宏观来看” in self narrative.

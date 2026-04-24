---
name: assist-archive-card
description: Short (<=3 turns) assist mode that produces an archive-first card (Reply + Archive Card) and stores it as a durable asset.
version: 1.0
---

# Assist Mode — Archive Card (<= 3 Turns)

## Purpose
Support **small, simple questions** inside Life Narrator without becoming a long chat product.
The outcome must be a **durable, reviewable asset** (an “Archive Card”), not a conversation transcript.

## Product rules (non-negotiable)
- Default intent is **Log** (pure recording). Assist mode must be explicitly triggered by user toggle or very-high confidence intent detection.
- Assist is **archive-first**: the assistant must output a compact card that can be saved.
- Assist is **short**: total interaction <= **3 turns** (user -> assistant -> user -> assistant). Only **one** clarification question is allowed.
- No long discussion. If the user wants deep exploration, they should use another AI tool and then **import/share** the transcript here for archiving.

## User experience summary
1) User enters Assist mode and sends a question (or pastes an external AI transcript).
2) Assistant returns:
   - **[Reply]** 1–2 sentences (acknowledge the ask)
   - **[Archive Card]** structured fields (editable + saveable)
3) User taps **Save as Record** (or Edit card) to store as atoms/tags, with a source link to the original input.

---

## Screens & UI

### Entry points
- Capture tab: input bar has an intent toggle: **Log (default)** / **Assist**
- Capture card actions: “Ask about this” (Assist)
- Import flow: “Import transcript” -> “Archive this” (Assist-Import)

### Assist result card layout (in capture feed)
- Section A: **Reply** (small text, 1–2 lines)
- Section B: **Archive Card** (editable fields)
- Actions:
  - Primary: **Save as Record**
  - Secondary: **Edit Card**
  - Tertiary: **End** (dismisses the assist UI state)
  - Optional: **Discard**

### Do NOT present as chatbot bubbles
Assist content should appear as a **light card under the capture item**, not as a full chat UI.

---

## Output template (must follow)

### [Reply]
- 1–2 sentences
- Acknowledge what the user asked and what the assistant did.

### [Archive Card] (fields)
- Title: (<= 12 words)
- Context (1 line):
- Key points: (max 3 bullets)
- Practice / Next step: (max 3 bullets, optional)
- Tags suggested: (1–3 total; prefer Project/Theme)
- Confidence: (low / medium / high)

### Hard constraints
- No moralizing, no coaching tone.
- No abstract “overall/in essence”.
- Prefer the user’s wording; avoid formal rewriting.
- Keep concise. Card should be quickly skimmable and searchable.

---

## AI I/O Contract

### Inputs
- `capture_id`
- `intent = assist`
- `payload`:
  - `question_text` OR `imported_transcript_text`
  - optional: `related_atoms` (<= 10, if user asked about a specific record/day/project)
- `persona_profile = stable_warm`
- `max_turns = 3`

### Outputs (JSON)
```json
{
  "reply": "…",
  "archive_card": {
    "title": "…",
    "context": "…",
    "key_points": ["…","…"],
    "next_steps": ["…"],
    "tag_suggestions": [
      {"tag_type":"theme","name":"…","score":0.7}
    ],
    "confidence": "medium"
  },
  "turn_policy": {"used_clarification": false, "turns_remaining": 1}
}
```

---

## Storage mapping
When user taps **Save as Record**:
- Create a Capture (if not already) storing Raw/Imported content.
- Store the Archive Card as either:
  - Option A: an `artifact` entity (recommended), OR
  - Option B: as a Narrative-like record + sources.
- Convert “Key points / Next steps” into Atoms:
  - key points -> `insight` / `thought` / `event` as appropriate
  - next steps -> `action`
- Apply tag suggestions to atoms.

---

## Edge cases
- If the question is too broad: ask **one** clarification question, then output the card.
- If user continues chatting after the card: respond with a polite closure + suggest external AI for deep talk.
- If imported transcript is very long: first summarize into the Archive Card; keep the raw text stored for traceability.

---

## Acceptance criteria
- Assist mode never exceeds 3 turns; only one clarification question max.
- The assistant always outputs the required template.
- UI clearly separates Reply vs Archive Card and offers Save/Edit/End.
- Saved card is discoverable via Tags and Search and traceable back to the raw input.

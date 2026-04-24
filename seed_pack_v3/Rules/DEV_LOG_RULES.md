---
name: dev-log-rules
description: Universal dev logging rules (Session/ADR/Change/Handover) for multi-AI handoff.
version: 1.1
---

# DEV_LOG_RULES (Universal, Required)

Any AI/dev session must keep the project handoff-friendly.  Every meaningful change must be **traceable**: what we did, why we did it, what it affects, and how we verified it.

## Required artifacts

- **Session Log (Layer A)** – `Docs/04_Sessions/YYYY-MM-DD_session-XXX.md`
- **ADR / Decision Log (Layer B)** – `Docs/03_Decisions/ADR-00X-<slug>.md` (when required)
- **Change Log (Layer C)** – `Docs/05_Changes/Change-00X-<slug>.md`
- **Handover** – `Docs/99_Handover/YYYY-MM-DD_<topic>.md` (used when switching AI mid‑task)

## Documentation layers (must maintain all three)

### Session Logs (Layer A)
Session Logs record the **chronological work narrative** of a single development session.

- Location: `Docs/04_Sessions/YYYY-MM-DD_session-XXX.md`
- Must include: goal, plan, work log, decisions (links), changes (links), verification, and next handoff notes.

### ADRs / Decision Logs (Layer B)
Any decision that affects future work must be recorded as an Architecture Decision Record (ADR).

- Location: `Docs/03_Decisions/ADR-00X-<slug>.md`
- Must include: context, alternatives, decision, rationale, consequences, and validation.
- Create an ADR if any of the following are true:
  - UX behaviour changes
  - Database schema or API contract changes
  - Privacy/security implications
  - Hard‑to‑reverse decisions
  - Team could disagree or forget in the near future

### Change Logs (Layer C)
A Change Log describes **what changed** and how to verify it.

- Location: `Docs/05_Changes/Change-00X-<slug>.md`
- Must include: what changed, files touched, user‑visible impact, verification steps, and rollback notes.

## Hard rules

**R1 — Start with intent** – Before writing code, create or update the Session Log.  Document the goal, related skills (e.g. `Skills/<skill>/SKILL.md`), and any constraints from `Rules/`.

**R2 — Link everything** – Session Logs must link to ADR(s) and Change Log(s) created during the session so future agents can follow the trace.

**R3 — Record failures and dead ends** – Significant failed attempts or dead ends must be documented (1–3 bullet points) to prevent repeated mistakes.

**R4 — Always include verification** – Every completed change must include verification steps: manual steps and/or automated tests.

**R5 — Keep docs searchable** – Every Session, ADR and Change must include metadata: date, owner (AI or person), scope (UI/DB/API/AI/Infra), related skills, and status (Draft/Accepted/Deprecated/Done).

**R6 — Handover when switching AI/tools** – If the work is interrupted mid‑feature or handed to another AI, create a handover file at `Docs/99_Handover/YYYY-MM-DD_<topic>.md` using the handover template.  Include current status, where to look, decisions/constraints, verification performed, and next steps.

## Minimum output requirements
During an agent run, the agent must:
1. Maintain a Session Log.
2. Create ADRs for key decisions when required.
3. Create Change Logs for shippable or verifiable changes.
4. Include verification steps and rollback notes.

## Definition of Done gate
No work is “done” unless:
- A Change Log exists.
- Verification steps exist.
- Rollback notes exist (if risky).
- Documentation is linked and searchable.

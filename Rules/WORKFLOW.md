# WORKFLOW (Universal)

Recommended loop:
1) Identify relevant Skills
2) Write/Update Session Log
3) Implement in small increments
4) Write Change Log for each shippable increment
5) Write ADR for key decisions
6) Verify and document verification steps
7) Handover doc if switching AI/tools mid-task

## Codex Handoff (when delegating to Codex / another AI agent)

Before handing a task to Codex, the design/spec owner must produce a **Codex Execution Brief**:

```
Docs/CODEX_EXECUTION_BRIEF_<YYYY-MM-DD>_iter-<NNN>.md
```

The brief must contain:
- **Iteration goals** (1–2 max)
- **Definition of Done** — acceptance criteria from relevant Skills
- **Frozen zones** — files/modules Codex must NOT touch
- **Known risks** — with mitigations
- **Affected files** — paths only, no source changes
- **Implementation steps** — ordered, step-by-step
- **Verification steps** — build + manual + test commands
- **Required log files** — Session Log + Change Log paths Codex must create

Codex reads the brief as its **first action** before writing any code.
See `Docs/CODEX_EXECUTION_BRIEF_2026-03-06_iter-001.md` for a reference example.

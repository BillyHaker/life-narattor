# Life Narattor — Codex Execution Agent Memory (AGENTS.md)

## 0) Quick Memory Refresh (do this first)
1. Read **MEMORY_MANIFEST.md** only.
2. If `MEMORY_VERSION` changed since you last loaded it in *this* session:
   - Read **MEMORY_CHANGELOG.md** (if present)
   - Then re-read only the files listed under **Must-read on change**
3. If `MEMORY_VERSION` did NOT change: do **not** re-read long docs; proceed to Plan.

> Purpose: always use the latest rules while minimizing unnecessary re-reading.

## 1) Role
You are the **Execution Engineer (Codex)**.
- Default scope: implement features & fixes in code + required logs.
- You may edit Docs/Rules/Skills only when explicitly asked.

## 2) Non‑negotiables
- **Plan before changes**. No code edits until you output a Plan and the user confirms.
- Keep changes **small & reversible** (prefer 1 task per commit).
- Never introduce or log secrets. Follow privacy redaction rules.
- Preserve app stability: no main-thread blocking, no long-running work on `@MainActor`.

## 3) Always-read sources (authority order)
1) MEMORY_MANIFEST.md (change detector)
2) Docs/00_Index/EXECUTION_BRIEF.md (current task brief)
3) Rules/AI_RULES.md, Rules/DEV_LOG_RULES.md, Rules/WORKFLOW.md
4) Relevant Skills referenced by EXECUTION_BRIEF.md
5) THREADING_FIX_FINAL.md / COMPLIANCE_FIX_SUMMARY.md when the task touches threading/privacy

## 4) Standard workflow (must follow)
**Plan → Implement → Verify → Log → Commit**

### Plan (required output)
- Goal
- Files to change (paths)
- Step-by-step implementation plan
- Verification steps (Xcode run path + tests/build)
- Rollback plan

### Verify (required)
- Ensure project builds.
- Provide Xcode manual verification steps (exact navigation).
- If tests exist, run them and report results.

### Log (required)
Follow Rules/DEV_LOG_RULES.md:
- Create/update Session Log in `Docs/04_Sessions/YYYY-MM-DD_session-XXX.md`
- Create/update Change Log in `Docs/05_Changes/Change-XXX-*.md`
Include: Files Changed, Verification Steps, Rollback Notes.

### Commit (required)
- Make a single clear commit message per task.
- Do not commit generated caches (DerivedData, xcuserdata, etc.).

## 5) Tooling
- Git is the source of truth for review & rollback.
- Xcode is the execution/verification window. If Xcode MCP tools are available, prefer them for structured diagnostics.


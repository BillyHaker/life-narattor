# Change-050 — Capture Detail Atomization Task Cancellation Guard

## Meta
- Date: 2026-03-06
- Owner: Codex (GPT-5)
- Scope: UI/Threading/Resilience
- Related Skills: atomization, error-handling-standard, acceptance-testing-min-bar, dev-logging-system
- Related ADRs: None
- Status: Done

## What changed
- Added a tracked atomization task handle in `CaptureDetailSheet`.
- Cancelled in-flight atomization when detail sheet disappears.
- Blocked overlapping atomization starts unless user explicitly retries with `force`.
- Added cancellation guard before post-await UI state writes.

## Files touched
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Docs/04_Sessions/2026-03-06_session-003.md`
- `Docs/05_Changes/Change-050-capture-detail-atomize-task-cancellation.md`

## Contracts/DB changes
- None.

## User-visible impact
- Reduced chance of stale/overlapping loading state when rapidly opening/closing detail sheet.
- No intentional UX copy or flow changes.

## Verification steps
1. Build verification:
   - `xcodebuild -project '/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-codex-fix/.derived build`
2. Expected result:
   - `** BUILD SUCCEEDED **`
3. Manual acceptance (Xcode):
   - Run app (`Cmd+R`) and create a capture with clean text.
   - Open detail sheet and immediately dismiss while spinner is visible.
   - Reopen same capture multiple times quickly.
   - Confirm no crash and no duplicated/incorrect persistent spinner state.

## Rollback plan
- Revert only this patch in `CaptureDetailSheet.swift` and remove this session/change log pair if needed.
- If rollback by git commit, revert the commit containing this change in the worktree branch.

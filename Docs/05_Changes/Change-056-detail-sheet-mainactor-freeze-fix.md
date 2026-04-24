# Change-056 — Detail Sheet MainActor Freeze Fix

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: UI/Threading/Resilience
- Related Skills: atomization, capture-ui, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Fixed potential UI freeze when opening capture/event detail by enforcing main-actor boundaries in `CaptureDetailSheet`:
  - `.task` entry now executes `reloadAtoms()` and `ensureAtomsIfNeeded()` inside `MainActor.run`.
  - `ensureAtomsIfNeeded(force:)` marked `@MainActor`.
  - Atomization task closure changed to `Task { @MainActor in ... }` before touching view state.
  - `reloadAtoms()` marked `@MainActor` to keep main-context Core Data fetches thread-safe.

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Docs/04_Sessions/2026-03-07_session-009.md`
- `Docs/05_Changes/Change-056-detail-sheet-mainactor-freeze-fix.md`

## Contracts/DB changes
- None.

## User-visible impact
- Opening event/capture detail should no longer freeze due to thread-unsafe state/context access.
- Detail sheet should present immediately and remain responsive while atomization continues.

## Verification Steps
1. Build:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `** BUILD SUCCEEDED **`
2. Launch:
   - `xcrun simctl install 5D4E15F7-AC23-454E-B304-9CFC19AD13A1 '/tmp/life-narrator-worktree-derived/Build/Products/Debug-iphonesimulator/Life Narattor.app'`
   - `xcrun simctl launch 5D4E15F7-AC23-454E-B304-9CFC19AD13A1 com.jintaoha.Life-Narattor`
   - Expected: returns PID (launch success)

## Rollback Notes
- Revert files listed in `Files Changed`, then rebuild and relaunch with the same commands.

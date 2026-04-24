# Change-060 — Transcription Error Reasons Visible

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: Voice/Transcription/UI/DB
- Related Skills: capture-ui, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Added persistent transcription error reason field:
  - `CaptureEntity.transcriptionError` (optional).
  - Included in managed object model (`PersistenceController`).
- Extended `CaptureItem` with `transcriptionErrorReason`.
- Updated data mapping layers to carry reason into UI models.
- Updated transcription queue to set/clear reason:
  - `pending/completed` clears reason.
  - `failed/offline` writes explicit reason by error class:
    - missing audio file
    - permission denied
    - empty recognition result
    - recognizer unavailable
    - timeout / network retry
    - simulated offline/failure
- UI updates:
  - `CaptureCardView`: show reason line for failed/offline.
  - `CaptureDetailSheet`: show reason line and status-aware fallback text.

## Files Changed
- `Life Narattor/Data/CaptureEntity.swift`
- `Life Narattor/Data/PersistenceController.swift`
- `Life Narattor/Models/CaptureItem.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureCardView.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Life Narattor/Screens/TimelineScreen.swift`
- `Life Narattor/Screens/DayDetailScreen.swift`
- `Life Narattor/Screens/SearchScreen.swift`
- `Life Narattor/Data/AtomizationCoordinator.swift`
- `Docs/04_Sessions/2026-03-07_session-013.md`
- `Docs/05_Changes/Change-060-transcription-error-reasons-visible.md`

## Contracts/DB changes
- Core Data model adds optional capture field `transcriptionError` (lightweight, backward-compatible expected).

## User-visible impact
- Voice capture cards and detail sheets now display clear failure reason text, not only generic status.
- Retry decisions become clearer (e.g., permission issue vs. temporary offline).

## Verification Steps
1. Build:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `EXIT:0`
2. Manual:
   - Trigger permission denied / offline sim / failure sim.
   - Expected: card + detail show specific reason text for each failed/offline state.

## Rollback Notes
- Revert files listed in `Files Changed`, then rebuild.

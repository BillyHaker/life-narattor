# Change 111 - Manual Retry Split Runs Immediately And Refreshes Detail State

## What Changed
- Changed `retryAtomization(captureID:)` to start a dedicated manual atomization task immediately when network is available, instead of only pushing the record back into `pendingSplit`.
- Added `captureProcessingStateChanged` notifications from `CaptureFeedViewModel` whenever split state changes.
- Updated `CaptureDetailSheet` to subscribe to those notifications and refresh both processing state and atoms in place.

## Why
The previous interaction made `重新拆分` look broken because the detail sheet kept showing the old snapshot state, and manual retry only re-queued the record instead of visibly starting work.

## Files Changed
- Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Views/CaptureDetailSheet.swift

## Verification Steps
- `node --check server/server.js`
- Code inspection of manual retry path and detail state refresh subscription

## Rollback Notes
- Remove manual atomization tasks and notification posting if you want all retries to go back through the pending queue only.

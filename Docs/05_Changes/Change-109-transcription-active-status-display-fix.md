# Change 109 - Transcription Active Status Display Fix

## What Changed
- Added `isTranscriptionActive` to `CaptureItem` and populated it from `CaptureFeedViewModel` using the live transcription task map.
- Updated record row, capture card, and detail sheet to show `正在转写…` / `转写中，请稍候` whenever a transcription task is still running, even if persisted status temporarily says offline or failed.
- Hid retry buttons and retry reasons while transcription is still active.
- Gated `isTranscriptionFailureSimulated` and `isTranscriptionOfflineSimulated` reads behind `#if DEBUG` in `FeatureFlags`.

## Why
The previous UI surfaced persisted retry/failure states during an active transcription lifecycle, which made new recordings look failed before they later succeeded. That status presentation was misleading.

## Files Changed
- Life Narattor/Models/CaptureItem.swift
- Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Screens/RecordFeedScreen.swift
- Life Narattor/Views/CaptureCardView.swift
- Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/DevTools/FeatureFlags.swift

## Verification Steps
- Inspect transcription queue state transitions in `CaptureFeedViewModel.runTranscriptionQueue`.
- Inspect UI rendering paths in `RecordFeedScreen`, `CaptureCardView`, and `CaptureDetailSheet`.

## Rollback Notes
- Remove `isTranscriptionActive` and revert UI to raw persisted status display if needed.

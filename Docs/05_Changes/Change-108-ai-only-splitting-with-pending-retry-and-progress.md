# Change 108 - AI Only Splitting With Pending Retry And Progress

## What Changed
- Removed local sentence-based atomization fallback from `AtomizationCoordinator`; splitting now only succeeds through AI atomization.
- Added internal processing states for split lifecycle: `pendingSplit`, `splitting`, and `splitFailed`.
- Updated text-capture ack completion and voice transcription completion to queue records for AI splitting instead of splitting immediately with fallback.
- Added a lightweight network monitor in `CaptureFeedViewModel` to auto-process pending unsplit records when connectivity returns.
- Added top progress UI in the record feed while queued splits are being processed.
- Added a manual `重新拆分` action in the detail split tab.
- Hid internal split lifecycle states from the main feed; users now continue to see a neutral recorded state until split output is ready.

## Why
The product requirement is to treat splitting as an AI-only standardization step. Offline capture should still succeed immediately, but splitting should wait for network and happen automatically later.

## Files Changed
- Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Data/AtomizationCoordinator.swift
- Life Narattor/Models/CaptureItem.swift
- Life Narattor/Screens/RecordFeedScreen.swift
- Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/Views/CaptureCardView.swift

## Verification Steps
- `node --check server/server.js`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback Notes
- Reintroduce local fallback atom creation in `AtomizationCoordinator` and remove queued retry logic.
- Remove the new split lifecycle states if product direction changes back to eager/local splitting.

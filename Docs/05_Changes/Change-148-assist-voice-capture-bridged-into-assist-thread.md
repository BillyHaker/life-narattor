# Change 148 - Bridge Assistant Voice Capture Into Assist Thread

## Summary
Fixed assistant-page voice input so recorded audio no longer dead-ends as a hidden `mode = assist` capture. After transcription completes, the cleaned transcript is now sent into the active assistant thread and processed as a normal assistant turn.

## What Changed
- Added `sourceThreadID` to `VoiceCaptureDraft`.
- When stopping a recording in assist mode, the current assist thread ID is attached to the draft.
- Persisted assistant voice captures now retain `sourceThreadID`.
- On transcription completion for assistant-mode captures:
  - processing stops at `cleanReady`
  - normal record auto-split is skipped
  - cleaned transcript is forwarded to `startAssistSessionTurn(...)`
- Added user notice: `语音转写完成，已发送给助手`.

## Why
The microphone UI was present on the assistant surface, and recording/transcription worked, but there was no bridge from completed transcription into the assistant chat pipeline. Users experienced this as "assistant voice input cannot be used".

## Files
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/ViewModels/CaptureFeedViewModel.swift`

## Verification
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build` => `EXIT:0`

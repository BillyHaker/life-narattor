# Change Log

- Change: Removed explanatory helper copy from the assistant recording card to make the voice input UI feel cleaner and more system-like.
- Date: 2026-04-19
- Owner: Codex

## Files Changed
- `Life Narattor/Views/RecordingChipView.swift`

## Summary
- Removed the secondary explanatory sentence under `正在录音`.
- Kept the recording timer, waveform, and stop/cancel actions unchanged.
- Preserved the single-mode recording layout introduced in the previous polish pass.

## Verification Steps
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
  - blocked by local simulator runtime availability (`No available simulator runtimes for platform iphonesimulator`)
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' -derivedDataPath /tmp/life-narrator-main-derived-device build`
  - blocked by local signing / provisioning profile availability when targeting generic iOS devices

## Rollback Notes
- Restore the removed helper sentence in `RecordingChipView.swift` if later product copy needs to be reintroduced.

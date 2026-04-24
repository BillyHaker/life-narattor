# Change 151 - AI Review First Answer Section Rendering

## Summary
Improved first-answer readability in AI Review by parsing `事实： / 联系： / 可继续问：` into short section blocks inside the assistant bubble instead of rendering the whole answer as one dense text block.

## What Changed
- Added lightweight section parsing for AI review answers.
- If the answer contains the expected labels, it now renders as:
  - section label
  - short body block
- Falls back to plain text bubble when no structured labels are found.

## Why
The first answer was still too dense even after the broader AI Review redesign. This change improves scanability without changing the retrieval or AI generation pipeline.

## Files
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Screens/SearchScreen.swift`

## Verification
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build` => `EXIT:0`

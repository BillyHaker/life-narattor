---
date: 2026-03-14
owner: Codex
scope: Voice/UI
status: Done
---

# Change Log

## What Changed
修复“重新转写”链路：重试转写时会清掉旧的转写、整理文本和拆分结果，并让详情页使用实时转写状态，而不是打开页面时的静态快照。

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`

## User-Visible Impact
- 点击 `重新转写` 后，不会再在“整理后”页看到占位文本 `语音记录。`
- 重转写期间，详情页会显示 `转写中，请稍候`。
- 旧的拆分结果会被清掉，转写完成后重新进入整理和拆分链路。

## Technical Summary
- `retryTranscription(captureID:)` 现在会重置：
  - `transcriptText`
  - `cleanText`
  - `processingState`
  - `atomizationError`
  - `atomsCount`
- 同时清除旧 atoms，并发送状态变更通知。
- `CaptureDetailSheet` 新增当前转写状态本地状态：
  - `currentTranscriptText`
  - `currentTranscriptionStatus`
  - `currentTranscriptionError`
  - `isRetryingTranscription`

## Verification Steps
1. 找一条已有语音转写的记录。
2. 点 `重新转写`。
3. 观察“整理后”页应显示 `转写中，请稍候`，而不是 `语音记录。`
4. 转写完成后应显示新的整理文本，并重新拆分。

## Rollback Notes
- 回滚 `retryTranscription(captureID:)` 中新增的清理逻辑。
- 回滚 `CaptureDetailSheet` 的实时转写状态字段，恢复为使用 `item` 快照。

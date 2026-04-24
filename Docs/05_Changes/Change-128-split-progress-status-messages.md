---
date: 2026-03-16
owner: Codex
scope: Split UX
status: Done
---

# Change Log

## What Changed
给记录详情页的 `重新拆分` 和自动拆分流程增加了明确的进行中状态提示，不再只显示模糊的“正在拆分…”。

## Files Changed
- `Life Narattor/Data/AtomizationCoordinator.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`

## User-Visible Impact
- 点击 `重新拆分` 后，用户现在会看到更具体的状态：
  - `已发送拆分请求…`
  - `已发送拆分请求，等待 AI 响应…`
  - `AI 已返回，正在整理拆分结果…`
  - `正在生成标签建议…`
- 拆分结束后，这些临时状态会自动清除，不会残留在详情页。

## Technical Summary
- 为 `atomizeCaptureIfNeeded(...)` 增加了可选进度回调。
- 复用现有 `captureProcessingStateChanged` 通知通道，附带 `atomizationStatusMessage` 用户信息。
- `CaptureDetailSheet` 新增本地状态字段接收并显示当前拆分阶段文案。
- `CaptureFeedViewModel` 在手动重试和自动拆分两条路径上统一推送阶段消息。

## Verification Steps
1. 打开一条尚未拆分或需要重新拆分的记录。
2. 点击 `重新拆分`。
3. 观察 `拆分` tab 是否按阶段显示进行中状态。
4. 等拆分完成，确认状态文案自动消失。
5. 执行 `xcodebuild` 确认构建通过。

## Rollback Notes
- 如需回退，可移除 `atomizationStatusMessage` 通知字段和 `CaptureDetailSheet` 中的本地状态显示，恢复统一的“正在拆分…”文案。

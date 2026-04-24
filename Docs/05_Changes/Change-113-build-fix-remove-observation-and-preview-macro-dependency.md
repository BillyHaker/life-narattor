---
date: 2026-03-14
owner: Codex
scope: Build/DevTools/Tests
related_skills:
  - dev-logging-system
status: Done
---

# Change Log

## What Changed
修复本轮构建失败，移除了当前 Xcode 环境下会触发宏插件故障的 Observation / Preview 宏依赖。

## Files Changed
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/DevTools/FeatureFlags.swift`
- `Life Narattor/DevTools/LogStore.swift`
- `Life Narattor/DevTools/AIDebugStore.swift`
- `Life Narattor/DevTools/DevToolsRootView.swift`
- `Life Narattor/DevTools/DevToolsAIDebugView.swift`
- `Life Narattor/ContentView.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Life NarattorTests/TranscriptionDebugStoreTests.swift`

## User-Visible Impact
- App 可重新构建。
- DevTools 仍可工作，但内部观测机制改为 `ObservableObject`。
- 预览功能改为 `PreviewProvider`，不影响运行时行为。

## Verification Steps
1. 执行 `xcodebuild ... build`。
2. 预期 `EXIT:0`。
3. 在 Xcode 中重新 Build，确认不再出现 `ObservableMacro` 或 `#Preview` 相关报错。

## Rollback Notes
- 若需回滚，可恢复 `@Observable` 与 `#Preview` 写法；但在当前 Xcode 环境下会重新引入宏插件构建风险。

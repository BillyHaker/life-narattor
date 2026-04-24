---
date: 2026-03-14
owner: Codex
scope: AI/UI/DB/API
related_skills:
  - atomization
  - error-handling-standard
status: Done
---

# Change Log

## What Changed
修复 atomize 失败被误显示为“等待网络恢复”的问题。

## Files Changed
- `Life Narattor/Data/CaptureEntity.swift`
- `Life Narattor/Data/PersistenceController.swift`
- `Life Narattor/Models/CaptureItem.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/Data/AtomizationCoordinator.swift`
- `server/server.js`

## User-Visible Impact
- 详情页“拆分”不再把所有 atomize 失败统一说成“网络可用后会自动拆分”。
- 手动“重新拆分”时会优先显示 `正在拆分…`。
- 若 atomize 返回格式异常、结果为空或服务异常，详情页会显示更准确的失败原因。

## Technical Summary
- 新增 `CaptureEntity.atomizationError` 保存拆分错误原因。
- `performAtomization(for:)` 成功时清空错误，失败时写入具体错误原因。
- `invalidResponse` / `emptyResponse` 现在归类为 `splitFailed`，不再进入 `pendingSplit`。
- `/v1/atomize` 的 `type` 改为严格枚举，减少 backend 返回不可解码值的概率。
- backend 解码失败统一转成 `AIServiceError.invalidResponse`。

## Verification Steps
1. 运行 `node --check 'server/server.js'`。
2. 在 app 中打开一条未拆分记录。
3. 点击“重新拆分”。
4. 预期：先显示 `正在拆分…`；若失败，显示真实原因，不再统一显示网络提示。
5. 若服务恢复正常，预期进入 `已拆分` 并展示拆分内容。

## Rollback Notes
- 回滚 `server/server.js` 可恢复旧 `/v1/atomize` schema。
- 回滚 `CaptureFeedViewModel.swift` 与 `CaptureDetailSheet.swift` 可恢复旧状态机和文案。
- 回滚 `CaptureEntity.swift` / `PersistenceController.swift` 会移除 `atomizationError` 字段；这是本次唯一 schema 变更。

---
date: 2026-03-14
owner: Codex
scope: Text/UI
related_skills:
  - clean-defiller
status: Done
---

# Change Log

## What Changed
实现并接入 `clean-defiller v1`，让“整理后”不再直接等于原始文本或原始转写。

## Files Changed
- `Life Narattor/Text/CleanDefiller.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`

## User-Visible Impact
- 文本记录创建后，“整理后”会显示轻度去噪后的文本。
- 语音转写完成后，“整理后”会显示去停顿、去重复、补轻标点的版本。
- 保留原始文本与原始转写，不做正式化改写。

## Technical Summary
- 新增规则清洗器 `CleanDefiller.clean(_:)`
- 输出结构包含：`cleanText / removedFillers / rulesetVersion`
- 当前 v1 使用本地规则，不调用 AI
- 已接入：
  - 新建文本记录
  - 语音转写成功
  - revision 覆盖写回

## Verification Steps
1. 新建一条文本记录，包含重复和口头词。
2. 打开详情页，对比“整理后”和“原始”。
3. 录一段包含重复/停顿的语音。
4. 转写完成后打开详情页，对比“整理后”和“原始”。
5. 预期：整理后更易读，但仍保持原口吻。

## Rollback Notes
- 回滚 `CaptureFeedViewModel.swift` 中三处 `CleanDefiller.clean(...)` 接入即可恢复旧行为。
- 删除 `Text/CleanDefiller.swift` 可完全移除本次 clean pipeline。

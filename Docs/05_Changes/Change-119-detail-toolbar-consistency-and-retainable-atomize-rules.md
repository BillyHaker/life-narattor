---
date: 2026-03-15
owner: Codex
scope: UI/AI
status: Done
---

# Change Log

## What Changed
统一记录详情页右上角按钮语义，并收紧拆分提示词：拆分按“值得保留的事项单元”进行，不再鼓励最小短语级碎拆。

## Files Changed
- `Life Narattor/Views/CaptureDetailSheet.swift`
- `Life Narattor/AI/AIService.swift`
- `server/server.js`

## User-Visible Impact
- `整理后` 页显示 `重新整理`
- `原始` 语音页显示 `重新转写`
- `拆分` 页显示 `重新拆分`
- 拆分模型会更偏向少拆、整块拆，而不是把修饰词和标签属性拆成独立记录

## Technical Summary
- `CaptureDetailSheet` toolbar 改为按当前 tab 决定动作按钮。
- OpenAI 直连和 backend `/v1/atomize` 的 instructions 改为：按用户真正想留下的事项拆分，修饰语/程度词/情绪色彩优先留给标签或属性，不单独成 atom。

## Verification Steps
1. 打开记录详情三页，确认右上角按钮与当前页动作一致。
2. 对一条较长记录重新拆分。
3. 检查拆分结果是否更接近“几件事”，而不是“几个短语”。

## Rollback Notes
- 回滚 `CaptureDetailSheet.swift` toolbar 分支可恢复旧按钮逻辑。
- 回滚 `AIService.swift` / `server/server.js` 的 atomize instructions 可恢复旧拆分倾向。

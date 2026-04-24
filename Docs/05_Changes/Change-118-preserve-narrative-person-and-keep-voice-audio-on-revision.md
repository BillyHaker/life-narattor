---
date: 2026-03-14
owner: Codex
scope: AI/Voice
status: Done
---

# Change Log

## What Changed
收紧 AI clean 规则，明确要求保持原本人称/叙事视角；同时修复语音记录在 revision 路径中被错误清空 `audioPath` 的风险。

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `server/server.js`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`

## User-Visible Impact
- AI 整理会更稳定地保留第一人称叙事，不把“我”改成第三人称或抽象叙述。
- 对语音记录做 revision 后，不会再因为代码路径把原始音频丢掉。

## Technical Summary
- 在 OpenAI 直连和 backend `/v1/clean` 提示词中加入：保留原始语法人称和叙事视角。
- `applyRevision(to:newText:threadID:)` 现在会识别原记录是否为语音：
  - 若是语音记录，保留 `inputType = voice`
  - 不再清空 `audioPath`
  - 不再清空已有 `transcriptText/transcriptionStatus`
- 当前录音文件保存位置已确认是 `Documents/recording-*.m4a`，不是临时目录。

## Verification Steps
1. 对一条语音记录执行 revision 路径。
2. 打开详情页原始 tab，确认音频仍可播放。
3. 对含第一人称的复杂转写执行 AI 整理。
4. 观察整理后是否仍保持第一人称叙事。

## Rollback Notes
- 回滚 `applyRevision(...)` 中 `wasVoiceCapture` 分支可恢复旧行为，但会重新引入音频丢失风险。
- 回滚 clean prompt 新增句子可恢复旧 AI 整理规则。

---
name: speech-transcription
description: Audio recording & transcription pipeline and UI hooks. Use this skill when specifying, implementing, or validating the Life Narrator iOS app feature set in this area. Follow the UI + behavior requirements exactly, and keep changes consistent with the North Star principles.
metadata:
  product: life-narrator
  version: "0.2"
  owner: product
changelog:
  - "v0.1: initial scaffold"
  - "v0.2 (2026-03-06): added V1 engine decision (on-device iOS Speech), implementation contract, V2 upgrade path, updated acceptance criteria"
---

# Speech Transcription

## Purpose
Audio recording & transcription pipeline and UI hooks.

## Scope
### In scope
- Audio recording & transcription pipeline and UI hooks.

### Out of scope
- Anything not listed above; if uncertain, default to the V1 boundaries in `product-northstar`.

## Definitions
- **Capture**: a single user input (text or voice) stored as Raw + Clean.
- **Raw**: original text/transcript, preserved verbatim.
- **Clean**: de-filled text (remove fillers/pauses/repeats), *not* formalized.
- **Atom**: smallest structured unit extracted from a Capture (event/feeling/action/etc.).
- **Narrative**: rendered story output (daily/weekly/project) built from Atoms.
- **AI Comment**: second-layer “friend reply” separated from self narrative.

## UI Requirements
### Screens & entry points
**Primary entry points**
- **Record tab → bottom input bar**
  - Tap `🎤` to start recording.
  - Recording UI appears as an inline “recording chip” above the input bar.

**Secondary entry points**
- **Capture expansion → 原始 (Raw) tab**: playback and transcript view.
- **Capture card status line**: retry transcription.

### Components
**Recording chip (inline)**
- Timer (mm:ss)
- Waveform / level indicator (optional)
- Buttons:
  - `⏹ Stop` (primary)
  - `Cancel`

**Capture card transcription status line**
- `正在转写…`
- `转写完成`
- `转写失败 · 重试`
- `离线中 · 稍后自动转写` (if offline)

**Playback UI (Capture expansion → 原始 tab)**
- Audio player controls (play/pause, scrub)
- Transcript area (raw transcript)
- Actions:
  - `复制转写`
  - `重新转写`

### Interactions
**Record flow**
1) User taps mic → request microphone permission if needed.
2) While recording, show recording chip. Keep the rest of UI usable (user can cancel).
3) User taps Stop → create a Capture with `input_type=voice`, store audio file path.
4) Immediately show the capture card in feed with placeholder text `语音记录` and status `正在转写…`.
5) When transcript arrives:
   - Save to `transcripts`.
   - Update capture display to show transcript (or, once Clean runs, show Clean).
   - Trigger Clean → Atomize pipeline.

**Cancel**
- If user cancels, discard audio and do not create a capture.

**Retry transcription**
- If failed, tap `重试` on capture card.
- Retry must re-use the stored audio file path.

**Edit transcript (optional V1)**
- If you allow editing, edits create a new `raw_text` override for the pipeline and invalidate downstream derived outputs.

### States
**Permissions**
- If mic permission denied: show explainer + CTA `去设置打开麦克风权限`.

**Offline**
- If server transcription is required and offline:
  - Save audio.
  - Queue transcription job.
  - Show `离线中 · 稍后自动转写`.

**No speech detected**
- Store audio-only capture and show `没有听清内容` with `重试`.

**Long audio**
- If exceeds max duration (choose a V1 cap, e.g., 5 min): auto-stop, or warn at 4:50.

**Background interruption**
- If app backgrounded or interrupted by call: stop recording and save partial; show banner `录音已保存（未完成）`.

## Data & Storage
- Persist to local database per `database-schema`.
- All derived outputs must be versioned (ruleset_version/style_version) and traceable to sources.

## AI Inputs/Outputs

### V1 引擎决策：iOS Speech 框架（本地）

**决定**：V1 使用 iOS 原生 `Speech` 框架（`SFSpeechRecognizer`）进行本地转写。

**选择原因**：

| 维度 | iOS Speech（本地） | 服务端 Whisper |
|------|--------------------|----------------|
| 隐私 | ✅ 数据不离设备 | ⚠️ 音频上传服务器 |
| 离线可用 | ✅ 无网络也可转写 | ❌ 需要网络 |
| V1 复杂度 | ✅ 无需后端依赖 | ❌ 需要服务端接口 |
| 中文准确率 | ⚠️ 一般（zh-CN 可接受） | ✅ 更高 |
| 长音频支持 | ⚠️ 有时长限制（约 60s/请求） | ✅ 无限制 |

**V1 局限性（已知、可接受）**：
- 中文口语准确率略低于 Whisper；用户可通过"重新转写"或手动编辑纠正。
- 单次请求有时长上限（约 60 秒）；超长音频需分段处理（V1 暂不实现，见 Edge cases）。

**V2 升级路径**：当服务端代理（`server/`）稳定后，可通过 `FeatureFlags.useServerTranscription` 切换至 Whisper 接口，无需改动 UI 层。

> 引擎选择对应 ADR 待补（`Docs/03_Decisions/ADR-010-speech-engine-v1.md`），当前以本 Skill 为准。

---

### V1 实现契约（iOS Speech 框架）

**使用的 iOS API**：
```
AVAudioSession      — 音频会话管理（category: .record → .playback）
AVAudioRecorder     — 录制音频，保存为 .m4a 文件
SFSpeechRecognizer  — 本地语音识别（locale: zh-CN）
SFSpeechAudioBufferRecognitionRequest — 流式识别请求
```

**语言设置**：
```swift
let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
```

**转写结果映射**：
```swift
// 识别完成后写入 CaptureEntity
capture.rawText = result.bestTranscription.formattedString
capture.transcribeEngine = "ios_speech_v1"
capture.transcribeConfidence = Float(result.bestTranscription
    .segments.map(\.confidence).reduce(0, +)
    / Double(result.bestTranscription.segments.count))
```

**权限申请时机**：用户首次点击麦克风时申请，拒绝后显示说明页。

---

### 输入契约（本地，无网络请求）

| 字段 | 类型 | 说明 |
|------|------|------|
| `audioFileURL` | `URL` | 本地 `.m4a` 文件路径 |
| `locale` | `String` | `"zh-CN"`（V1 固定） |

### 输出契约（写入 CoreData）

| 字段 | 类型 | 来源 |
|------|------|------|
| `rawText` | `String` | `bestTranscription.formattedString` |
| `transcribeEngine` | `String` | `"ios_speech_v1"` |
| `transcribeConfidence` | `Float` | 各片段置信度均值 |

### 下游触发
- 转写完成后，触发 Clean 流水线，传入 `raw_text = capture.rawText`。

---

### 服务端契约（V2 预留，当前不实现）

```json
{
  "capture_id": "cap_...",
  "audio_url": "file:///...",
  "language": "zh",
  "return_segments": true
}
```

```json
{
  "capture_id": "cap_...",
  "raw_transcript": "...",
  "segments": [
    {"t0_ms": 0, "t1_ms": 1200, "text": "..."}
  ],
  "confidence": 0.86,
  "engine": "whisper_server"
}
```

## Edge cases
- Mixed languages in speech → keep transcript; Clean handles filler removal.
- Very noisy audio → low confidence; still store; allow user to edit later.
- Large audio files → compress before upload.
- Duplicate retries → ensure latest transcript wins (overwrite transcript row).

## Acceptance criteria

- 用户可在主界面输入栏录音，松开后立即看到 Capture 卡片（`语音记录 · 正在转写…`）。
- 转写异步完成后更新 Capture 卡片（成功显示文字；失败显示可操作的重试入口）。
- **V1 必须离线可用**：无网络时转写依然执行（iOS Speech 本地引擎），不出现"需要联网"错误。
- 音频文件保存在本地，可从 Capture 详情页播放，即使转写已完成。
- 转写引擎信息（`transcribeEngine = "ios_speech_v1"`）写入数据库，便于未来区分 V1/V2 数据。
- 用户拒绝麦克风权限时，显示说明文案和"去设置"按钮，不崩溃。

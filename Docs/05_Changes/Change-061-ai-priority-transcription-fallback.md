# Change-061 — AI-Priority Transcription With Local Fallback

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: Voice/AI/FeatureFlags
- Related Skills: ai-interaction, capture-ui, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Extended AI abstraction with transcription:
  - `AIService.transcribeAudio(fileURL:locale:)`.
- Implementations:
  - `OpenAIService`: multipart upload to `/v1/audio/transcriptions` (model: `whisper-1`).
  - `BackendAIService`: returns unsupported (safe fallback path).
  - `MockAIService`: returns mock transcript text.
- Added `HybridVoiceTranscriptionService`:
  - uses local speech transcription by default.
  - when feature flag enabled, tries AI first and falls back to local speech on error.
- Updated `CaptureFeedViewModel` to default to hybrid transcription service.
- Added feature flag + UI:
  - `FeatureFlags.isAITranscriptionPreferred`
  - DevTools toggle: `Prefer AI Transcription`.
- Adjusted recording preflight:
  - speech permission preflight required only when AI-priority is disabled.

## Files Changed
- `Life Narattor/AI/AIService.swift`
- `Life Narattor/VoiceTranscriptionService.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Life Narattor/DevTools/FeatureFlags.swift`
- `Life Narattor/DevTools/DevToolsRootView.swift`
- `Docs/04_Sessions/2026-03-07_session-014.md`
- `Docs/05_Changes/Change-061-ai-priority-transcription-fallback.md`

## Contracts/DB changes
- None.

## User-visible impact
- App remains stable with local transcription as baseline.
- In DevTools, enabling `Prefer AI Transcription` allows testing AI transcription path while keeping local fallback safety.

## Verification Steps
1. Build:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `EXIT:0`
2. Manual:
   - Toggle `Prefer AI Transcription` off: local transcription path.
   - Toggle on with AI configured: AI path attempted; on AI error should fallback to local transcription.

## Rollback Notes
- Revert files listed in `Files Changed`, then rebuild.

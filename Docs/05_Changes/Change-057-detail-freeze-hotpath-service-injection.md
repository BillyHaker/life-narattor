# Change-057 — Detail Freeze Hotpath Service Injection

## Meta
- Date: 2026-03-07
- Owner: Codex (GPT-5)
- Scope: UI/Performance/Resilience
- Related Skills: atomization, capture-ui, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Reduced detail-open freeze risk by removing repeated AI service construction from hot SwiftUI update paths.
- `ContentView`:
  - Replaced computed `aiService` getter with stable stored instance initialized once in `init`.
- `RecordFeedScreen`:
  - Stored injected `aiService` and explicitly passed it to `CaptureDetailSheet` when presenting detail sheet.
  - Called `viewModel.activateIfNeeded()` in `.onAppear`.
- `CaptureFeedViewModel`:
  - Removed `registerRecordingObservers()` side effect from `init`.
  - Added `activateIfNeeded()` guard to register observers exactly once on real screen appearance.

## Files Changed
- `Life Narattor/ContentView.swift`
- `Life Narattor/Screens/RecordFeedScreen.swift`
- `Life Narattor/ViewModels/CaptureFeedViewModel.swift`
- `Docs/04_Sessions/2026-03-07_session-010.md`
- `Docs/05_Changes/Change-057-detail-freeze-hotpath-service-injection.md`

## Contracts/DB changes
- None.

## User-visible impact
- Opening event/capture detail from Record tab should no longer trigger UI hang caused by repeated service/viewmodel side effects during view graph updates.
- App launch and navigation remain unchanged.

## Verification Steps
1. Build:
   - `xcodebuild -project '/private/tmp/life-narrator-codex-fix/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-worktree-derived build`
   - Expected: `EXIT:0` / build success.
2. Install + launch:
   - `xcrun simctl install 5D4E15F7-AC23-454E-B304-9CFC19AD13A1 '/tmp/life-narrator-worktree-derived/Build/Products/Debug-iphonesimulator/Life Narattor.app'`
   - `xcrun simctl launch 5D4E15F7-AC23-454E-B304-9CFC19AD13A1 com.jintaoha.Life-Narattor`
   - Expected: returns PID.
3. Sample check (post-fix):
   - `sample <pid> 3 -file /tmp/life_narrator_postfix_sample.txt`
   - `rg` for prior hotspots in sample file:
     - `default argument 2 of CaptureDetailSheet.init`
     - `CaptureFeedViewModel.registerRecordingObservers`
     - `ContentView.aiService`
   - Expected: no matches.

## Rollback Notes
- Revert the files listed in `Files Changed`, then rebuild/relaunch using the same commands.

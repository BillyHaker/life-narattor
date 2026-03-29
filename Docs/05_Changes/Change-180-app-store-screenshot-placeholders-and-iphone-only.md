# Change 180 — App Store Placeholder Screenshots and iPhone-only Beta Submission

## What Changed
- Switched the app target to iPhone-only for the current beta submission path.
- Removed iPad orientation entries from the app target build settings.
- Generated placeholder App Store screenshots at a valid 6.9-inch iPhone resolution.

## Files Touched
- `Life Narattor.xcodeproj/project.pbxproj`
- `AppStoreAssets/iPhone-6.9/01-record-home.png`
- `AppStoreAssets/iPhone-6.9/02-voice-transcription.png`
- `AppStoreAssets/iPhone-6.9/03-assistant-chat.png`
- `AppStoreAssets/iPhone-6.9/04-draft-editor.png`
- `AppStoreAssets/iPhone-6.9/05-ai-review.png`
- `AppStoreAssets/iPhone-6.9/README.txt`
- `Docs/04_Sessions/2026-03-29_session-001.md`
- `Docs/05_Changes/Change-180-app-store-screenshot-placeholders-and-iphone-only.md`

## User-Visible Impact
- The current beta build now targets iPhone only.
- A valid placeholder screenshot set is available for App Store Connect upload.

## Verification Steps
1. Build the app:
   - `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
2. Confirm screenshot sizes:
   - `sips -g pixelWidth -g pixelHeight AppStoreAssets/iPhone-6.9/*.png`
3. Manual path:
   - Open App Store Connect screenshot upload.
   - Use the generated 6.9-inch files from `AppStoreAssets/iPhone-6.9/`.

## Rollback Notes
- Revert `Life Narattor.xcodeproj/project.pbxproj` to restore iPad support.
- Delete `AppStoreAssets/iPhone-6.9/` if the placeholder set is no longer needed.

## Screenshot Format Follow-up
- Added a second screenshot set under `AppStoreAssets/iPhone-6.7/` at `1284 x 2778`, matching the App Store Connect size requirements shown during upload.
- Kept the earlier placeholder set for reference, but the 6.7-inch folder should be used for upload.

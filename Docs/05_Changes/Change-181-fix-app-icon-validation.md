# Change-181 Fix App Icon Validation

## Summary
- Added a complete iPhone app icon asset set to `AppIcon.appiconset`.
- Updated the asset catalog manifest to reference the generated icon PNG files.
- Added `CFBundleIconName = AppIcon` to the app target build settings so archive validation can resolve the icon set.

## Files Changed
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png`
- `Life Narattor/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`
- `Life Narattor.xcodeproj/project.pbxproj`

## Verification
- `sips -g pixelWidth -g pixelHeight Life\ Narattor/Assets.xcassets/AppIcon.appiconset/*.png`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`
  - failed due local `iphonesimulator` runtime availability, not due icon assets
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS' -derivedDataPath /tmp/life-narrator-main-derived-device build`
  - failed due local signing/provisioning profile availability, not due icon assets

## Rollback Notes
- Revert `Life Narattor.xcodeproj/project.pbxproj` and `Life Narattor/Assets.xcassets/AppIcon.appiconset/Contents.json`.
- Delete the generated PNG icon files from `AppIcon.appiconset`.

## Follow-up Fix
- Regenerated the full icon set as non-transparent RGB PNG files after App Store validation reported an alpha channel in the large app icon.
- Kept filenames and asset catalog entries unchanged so the fix stays minimal and archive-safe.

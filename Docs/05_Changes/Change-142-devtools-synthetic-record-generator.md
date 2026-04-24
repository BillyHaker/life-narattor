# Change 142 - DevTools Synthetic Record Generator

## What Changed
- Added a DevTools synthetic record generator for office-worker, student, and mixed fixtures.
- Added configurable volume, time horizon, and optional immediate split/tag processing.
- Added synthetic capture cleanup so repeated test runs do not permanently pollute local fixture data.

## Files Changed
- /Users/billyha/Desktop/Life Narattor/Life Narattor/ContentView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsRootView.swift
- /Users/billyha/Desktop/Life Narattor/Life Narattor/DevTools/DevToolsSyntheticRecordsView.swift

## Verification
- xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build

## Rollback Notes
- Remove the generator view and synthetic fixture marker if test data generation should move outside the app.

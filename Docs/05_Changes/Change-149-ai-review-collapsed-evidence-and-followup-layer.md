# Change 149 - AI Review Collapsed Evidence and Follow-up Layer

## Summary
Refined the AI Review page so evidence groups default to collapsed and the user can ask deeper follow-up questions against the current retrieved review material without triggering a full new search.

## What Changed
- Evidence groups in `SearchScreen` no longer auto-expand by default.
- Added a follow-up interaction layer below the main AI review answer.
- Added follow-up suggestion chips tuned by retrieval mode (`overview` vs `focused`).
- Added inline follow-up Q/A cards to keep deeper analysis in the same review context.
- Extended AI analysis calls to support `followupQuestion` for:
  - `FocusedEvidenceBundle`
  - `NarrativeMaterial`
- Updated backend `/v1/focused-analysis` and `/v1/review-analysis` to support `followup_question` and return short, evidence-bound follow-up answers.

## Why
The page needed to behave more like a review workspace:
- first show a concise result,
- keep evidence out of the first visual layer,
- allow deeper questioning based on the current material,
- avoid rerunning global retrieval for every follow-up.

## Files
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Screens/SearchScreen.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/AI/AIService.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Screens/WeeklyReviewScreen.swift`
- `/Users/billyha/Desktop/Life Narattor/Life Narattor/Screens/MonthlyReviewScreen.swift`
- `/Users/billyha/Desktop/Life Narattor/server/server.js`

## Verification
- `node --check '/Users/billyha/Desktop/Life Narattor/server/server.js'`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build` => `EXIT:0`

# Change 107 - Assist Record Units And Structured Split View

## What Changed
- Added `recordUnits` to `AssistArchiveCard` and introduced `AssistRecordUnit` as a normalized split-record structure.
- Updated assist archive generation schema to request 1-4 topic-level record units instead of only flat key points.
- Changed assist archive atom creation to emit one atom per split unit summary.
- Updated capture detail "拆分" rendering to show structured split-unit cards for assist-derived records.
- Preserved backward compatibility by deriving a fallback record unit from existing title/context/keyPoints/nextSteps when no explicit record units are present.

## Why
The previous implementation treated archive key points as final split items, which produced sentence fragments instead of meaningful derived records. The new shape aligns the archive flow with the intended "standardize then split" model.

## Files Changed
- Life Narattor/Models/AssistArchivePayload.swift
- Life Narattor/AI/AIService.swift
- server/server.js
- Life Narattor/Data/AtomTagStore.swift
- Life Narattor/ViewModels/CaptureFeedViewModel.swift
- Life Narattor/Views/CaptureDetailSheet.swift
- Life Narattor/Views/AssistArchiveCardView.swift
- Life Narattor/Views/AssistArchiveEditSheet.swift

## Verification Steps
- `node --check server/server.js`
- `xcodebuild -project '/Users/billyha/Desktop/Life Narattor/Life Narattor.xcodeproj' -scheme 'Life Narattor' -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/life-narrator-main-derived-escalated build`

## Rollback Notes
- Remove `recordUnits` from `AssistArchiveCard` and restore flat `keyPoints/nextSteps` archive rendering.
- Restore `AtomTagStore.createAtoms(fromArchive:)` to emit one atom per key point / next step.

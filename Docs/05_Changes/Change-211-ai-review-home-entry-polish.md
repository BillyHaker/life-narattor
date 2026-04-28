# Change 211 — AI Review home entry polish

## Summary
Polished the AI Review home screen so it prioritizes user-record-derived clues, clarifies the direct question entry, and reduces visual noise in clue cards.

## Changes
- Reworded the input card to frame AI Review as discovering patterns in recent records.
- Changed the primary button text to `开始回顾`.
- Moved clue suggestions above generic examples when clues are available.
- Renamed `最近线索` to `从这些线索开始` and clarified that these clues are discovered from recent records.
- Renamed `可以这样问` to `试着这样问` and reduced examples to a lighter auxiliary role.
- Reworked clue cards to use quieter backgrounds, a chevron affordance, two-line title support, and user-facing `片段` copy.
- Preserved existing clue tap behavior and retrieval behavior.

## Files Changed
- `Life Narattor/Screens/SearchScreen.swift`
- `Docs/VERIFICATION_BACKLOG.md`

## Verification
- `git diff --check` passed.
- Static copy scan passed and confirmed old `条材料` / `点一下回看` / `最近线索` copy no longer appears in the AI Review home screen.
- Debug build passed.
- Release build passed.
- `Life NarattorTests` passed on iPhone 17 Pro Max simulator.

## Rollback
Revert this change commit. The change is presentation-only; the retrieval plan, tag filtering, and AI request flow were intentionally left unchanged.

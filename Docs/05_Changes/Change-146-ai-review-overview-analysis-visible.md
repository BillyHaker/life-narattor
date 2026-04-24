# Change 146 - AI review overview analysis visible

## What changed
- Added overview-mode AI analysis rendering to `SearchScreen`.
- Overview queries now build `NarrativeMaterial`, request AI narrative analysis, and show an `AI 分析` card before related records.
- Kept focused analysis behavior unchanged.

## Why
- Overview queries like `我过去一周主要发生了什么变化` were returning relevant records but no visible AI analysis.
- This created a misleading gap in the AI review experience, making overview mode look incomplete.

# Change 145 - Overview time review intent fix

## What changed
- Added broad open-review query detection in `RetrievalPlanBuilder`.
- Queries with a broad time window plus overview intent (for example `过去一周主要发生了什么变化`) now resolve to `openReview` instead of `comparison`.
- Comparison classification now requires a stronger signal: `前后`, `对比`, or a usable comparison anchor around `变化`.

## Why
- These broad review queries were previously misclassified as focused comparison questions.
- Focused retrieval without anchor/tag matches produced zero-score results, causing a false `没有记录` response even when records existed in the time range.

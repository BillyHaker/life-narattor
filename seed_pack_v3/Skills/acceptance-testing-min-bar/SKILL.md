---
name: acceptance-testing-min-bar
description: Minimum acceptance and testing bar per feature type (UI/Data/AI contracts).
version: 1.0
tags:
  - testing
  - acceptance
  - quality
---
# Acceptance & Testing Minimum Bar

## UI features
- Manual verification steps (simulator/device as needed)
- Empty/loading/error states verified

## Data/DB features
- Migration plan (if schema changes)
- Backward compatibility statement
- Rollback steps

## AI contract features
- Example JSON request/response
- Golden fixtures (sample inputs + expected outputs)
- Fallback behavior when slow/fails

## DoD
A feature is not done unless acceptance criteria + verification steps exist.

---
name: acceptance-testing-min-bar
description: Minimum acceptance and testing bar per feature type, including mandatory detection plans for change proposals.
version: 1.1
tags:
  - testing
  - acceptance
  - quality
---
# Acceptance & Testing Minimum Bar

## Proposal Detection Plan
Every non-trivial change proposal must include a detection plan before implementation starts. The detection plan must be concrete enough that another engineer can verify whether the intended change was actually implemented and whether it worked.

A valid detection plan includes:
- Expected behavior: what should be visibly or programmatically different after the change.
- Detection path: exact checks to run, such as Xcode build/test commands, simulator navigation, DevTools screens, logs, fixtures, or data inspection.
- Pass criteria: the specific result that proves the change succeeded.
- Failure signals: symptoms that indicate the change did not apply, only partially applied, or caused a regression.
- Regression surface: nearby behaviors that should still be checked because they are likely to be affected.

Avoid vague checks such as "test it" or "verify it works". Prefer observable checks: screen state, persisted data, API payload, logs, unit test assertion, or command output.

## UI features
- Manual verification steps (simulator/device as needed)
- Empty/loading/error states verified
- Detection plan must name the exact screen, action, and expected visual/state change.

## Data/DB features
- Migration plan (if schema changes)
- Backward compatibility statement
- Rollback steps
- Detection plan must include persisted-data inspection or a test proving old and new records behave correctly.

## AI contract features
- Example JSON request/response
- Golden fixtures (sample inputs + expected outputs)
- Fallback behavior when slow/fails
- Detection plan must include at least one controlled prompt/input and the expected structured behavior, not only a subjective quality judgment.

## DoD
A feature is not done unless acceptance criteria, a proposal detection plan, and verification steps exist.

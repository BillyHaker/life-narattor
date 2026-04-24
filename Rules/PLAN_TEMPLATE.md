# PLAN_TEMPLATE (Universal)

Use this template to outline your plan before undertaking a non-trivial task. A good plan makes it easy for any AI or human to understand what will be done, why it matters, and how success will be measured.

## Goal
Describe the desired outcome of this task in one or two sentences.

## Success Criteria
Define measurable indicators for success, such as acceptance tests pass, performance targets met, or user feedback. Success criteria should align with project goals.

## Detection Plan
Explain how this proposal will be proven effective before implementation starts. Include:
- Expected behavior: what should change after the work is complete.
- Detection path: exact automated checks, manual navigation, DevTools/log checks, fixtures, or data inspection steps.
- Pass criteria: what result counts as success.
- Failure signals: what would show the change failed or only partially worked.
- Regression surface: adjacent flows that must still behave correctly.

The detection plan must be specific enough that a different engineer can run it without guessing. Do not rely on vague statements like "verify it works".

## Constraints
List any technical, time, resource or regulatory constraints that apply.

## Assumptions
List assumptions that must hold true for the plan to be valid. If uncertain, call them out here.

## Affected Files / Components
Enumerate the files, modules or components expected to be created or modified. This helps downstream agents understand the impact area.

## Plan (Steps)
Outline the sequence of actions required to achieve the goal. Break the work into small, incremental steps:
1. First step...
2. Second step...
3. ...

## Test Strategy
Describe how you will verify the work. Include unit tests, integration tests and acceptance tests as appropriate. If manual verification is required, outline the steps.

## Risks & Mitigations
List potential risks, such as technical, schedule, or integration risks, and describe mitigation strategies. Identify fallback options if the plan fails.

## Verification
Explain how you will confirm that success criteria and the Detection Plan are met. Reference exact automated tests, commands, manual checks, fixtures, or inspection points.

## Rollback Plan
Describe how to revert to the previous state if the implementation fails or causes regressions.

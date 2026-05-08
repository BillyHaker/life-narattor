# ADR-019 - Purposeful Onboarding Flow

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: UX/Onboarding
- Status: Accepted
- Related change: [Change 238 - Purposeful Onboarding Flow](../05_Changes/Change-238-purposeful-onboarding-flow.md)

## Context
The first-run guide had become a set of feature explanations. Each page contained a title, detail, action pill, and multiple checklist lines. Although accurate, the experience felt fragmented: users were asked to absorb several product concepts before they had a clear reason to care.

The product direction is lower-pressure recording: users should feel that short, messy, incomplete fragments are enough. AI should appear as a later helper for organizing and reviewing, not as a heavy feature list.

## Alternatives
- Keep four feature pages and only polish wording. This would reduce some friction but keep the fragmented structure.
- Remove onboarding entirely. This would reduce interruption, but new users would not understand assistant-assisted records, Timeline, or AI Review.
- Replace the feature tour with a short three-step usage path.

## Decision
Use a three-step onboarding path:
1. Reduce pressure: users do not need to write a complete diary.
2. Explain the two capture modes: direct record or assistant-assisted draft.
3. Explain the later value of AI: Timeline and AI Review help find relationships after records accumulate.

Each page should have one purpose, one action explanation, and one example. Avoid multi-item checklists in the first-run guide.

## Rationale
- A new user needs permission to start lightly more than they need a tour of every feature.
- Direct recording and assistant-assisted recording are two paths to the same outcome, so they should be explained together.
- Timeline and AI Review both support later reflection, so they should be framed as the value created by accumulated records.
- One example per page is enough to make the behavior concrete without turning onboarding into documentation.

## Consequences
- Settings now describes the replay guide as `3 步` instead of `4 步`.
- The guide no longer separately introduces Timeline and AI Review as two independent feature pages.
- Manual visual verification remains important on small devices because onboarding is text-heavy.

## Validation
- Build must pass.
- Full test suite should pass.
- Fresh launch after privacy consent should show three pages.
- Final CTA should read `开始记一句` and enter the Record tab.
- Settings -> `重新看使用引导` should reopen the three-step guide.

# ADR-016 - Free Tier Only Launch

## Metadata
- Date: 2026-05-03
- Owner: Codex
- Scope: Product/Backend/UX
- Status: Accepted
- Related skills: None

## Context
The app previously prepared a 7-day trial and future paid tiers, but the immediate launch goal is to keep the product simple and avoid adding a payment decision before the user understands the value. Cost control is still necessary because AI and transcription requests consume backend provider quota.

## Alternatives
- Keep the 7-day trial and planned paid tiers visible. This adds commercial complexity too early and can make the settings page feel unfinished.
- Remove all backend quotas. This is simpler for users but creates unacceptable token/cost risk.
- Launch with one public free tier and a monthly AI credit limit, while keeping internal override tiers for review/testing.

## Decision
Launch the current public app as free-tier-only. Public users default to `free` and receive a monthly AI credit pool. Paid subscriptions are not exposed in the app. Internal override tiers such as `reviewer`, `trial`, `daily`, and `deep` may remain in backend code for manual testing and App Review, but they are not current product plans.

## Rationale
- A single free tier reduces user pressure and makes the first public version easier to explain.
- Monthly AI credits keep backend spending bounded.
- Internal override tiers preserve operational flexibility without showing unfinished paid features.

## Consequences
- Settings must clearly say that paid subscription is not currently available.
- StoreKit integration is deferred.
- Backend documentation and deployment defaults must avoid starting new users on trial automatically.

## Validation
- With no usage environment overrides, a fresh user resolves to `free`.
- Free users can consume AI credits until the monthly free pool is exhausted.
- Exhaustion returns `ai_credit_exhausted` and the app shows a human-readable free-quota message.
- Settings shows `免费版` and no `7 天试用` or active paid-tier wording.

# Change 243 - Conservative Atomization Causality Guard

## Metadata
- Date: 2026-05-09
- Owner: Codex
- Scope: AI/Atomization/Causality Safety
- Status: Done
- Related session: [2026-05-09 Session 001](../04_Sessions/2026-05-09_session-001.md)

## Goal
Prevent record atomization from turning co-occurring or time-adjacent facts into definite causal claims unless the user's original record explicitly says so.

## Implementation
- Added `AtomizationCausalityGuard` for deterministic local protection.
- The guard runs after `aiService.atomize(...)` and before atom payload/atom writes.
- If the source text has no explicit causal marker but AI output contains strong causal wording, the app strips or downgrades that wording.
- Updated OpenAI direct atomization prompt to require explicit causal markers.
- Updated backend `/v1/atomize` prompt with the same instruction.
- Added a server-side guard so backend responses are also protected after deploy.
- Added focused unit tests for inferred causality, explicit causality, co-occurring symptoms, and parallel contrast facts.

## User-visible Impact
- Records like `昨天睡得晚，今天醒来嗓子疼` should remain adjacent facts, not be rewritten as `因为昨天睡得晚...`.
- Records that explicitly say `因为...所以...` can still preserve causality.
- Existing record detail UI and stored schema are unchanged.

## Verification
- `node --check server/server.js` passed.
- `git diff --check` passed.
- `xcodebuild -project "Life Narattor.xcodeproj" -scheme "Life Narattor" -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:Life\ NarattorTests/AtomizationCausalityGuardTests test` passed.
- `xcodebuild -project "Life Narattor.xcodeproj" -scheme "Life Narattor" -configuration Debug -destination 'generic/platform=iOS Simulator' build` passed.

## Manual Verification
- Record detail -> retry split for `昨天睡得晚，今天醒来嗓子疼。`; no definite causality should appear.
- Retry split for `因为昨天睡得晚，所以今天很困。`; explicit causality can remain.

## Rollback
- Revert the final commit. No database migration, UI migration, or backend storage change is involved.

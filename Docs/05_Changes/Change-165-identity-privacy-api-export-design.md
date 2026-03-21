# Change-165 Identity, Privacy, API, and Export Design

## Summary
Added a formal product design draft for account identity, privacy boundaries, hosted API safety, user-supplied API support, and data extract/export strategy.

## Files Changed
- `Docs/01_Product/Identity_Privacy_API_Export_Design.md`
- `Docs/04_Sessions/2026-03-21_session-001.md`
- `Docs/05_Changes/Change-165-identity-privacy-api-export-design.md`

## Key Points
- Defined `user_id` as the primary long-term account identity and positioned Apple ID as an auxiliary auth/recovery method.
- Captured a local-first privacy model in which record content remains on device by default.
- Defined the hosted AI proxy model and the protection requirements for future user-supplied API credentials.
- Documented why structured intermediate artifacts should remain extractable for future export, migration, sync, and AI reuse.

## Verification
- Reviewed current product architecture and beta-launch constraints before writing the design draft.
- Verified the design draft explicitly answers identity inheritance, privacy, API safety, BYO-API, and extractability questions.

## Rollback Notes
- Safe to remove or revise this design document without affecting runtime behavior.

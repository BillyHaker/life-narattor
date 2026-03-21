# Identity, Privacy, API, and Export Design

Last updated: 2026-03-22
Status: Draft for implementation guidance

## 1. Purpose
This document defines the product and architecture strategy for:
- stable user identity across beta and production
- privacy boundaries for local and server-side data
- safe use of platform-hosted AI APIs
- future support for user-supplied AI APIs
- long-term extract/export capability

The goal is to let the product ship a test version now without blocking future production evolution.

---

## 2. Core principles

### 2.1 Local-first content storage
By default, user-generated content is stored locally on device.
This includes:
- records
- audio files
- transcripts
- cleaned text
- split record units
- assistant-generated draft records

### 2.2 Server stores identity and usage, not default full content
In early beta and early production, the server should primarily store:
- stable user identity
- device linkage
- API usage and quota data
- anonymous product metrics
- optional lightweight retrieval/index metadata when explicitly designed

The server should **not** assume full record-body sync by default.

### 2.3 Stable account identity must survive app upgrades
Data inheritance from beta to production should rely on a stable `user_id`, not on app version transitions and not on device-only identifiers.

### 2.4 Platform AI and user-supplied AI should coexist
The architecture should support both:
- hosted platform mode
- user-supplied provider mode

### 2.5 Extractability is a product capability, not an afterthought
Structured intermediate data should remain exportable and reusable.

---

## 3. Identity model

## 3.1 Primary identity
The system should use a stable backend-issued `user_id` as the primary identity key.

Recommended supporting identifiers:
- `user_id`: canonical account identity
- `device_id`: per-device helper identity
- `session_token`: authentication / authorization credential

## 3.2 Why `user_id` should be primary
Using `user_id` as the canonical identity makes the following stable:
- beta-to-production migration
- multi-device support later
- quota accounting
- support/admin operations
- future cloud sync

## 3.3 Role of device identifiers
`device_id` should be treated as a secondary technical identifier only.
Use it for:
- device linkage
- rate abuse analysis
- debugging
- lost-session recovery assistance

Do **not** use `device_id` as the sole long-term identity.

---

## 4. Apple ID as auxiliary identity

## 4.1 Recommendation
Apple ID / Sign in with Apple should be treated as an **identity recovery and login method**, not as the raw primary database identity.

Recommended approach:
- user signs in with Apple
- backend creates or links an internal `user_id`
- Apple identity becomes an authentication provider linked to `user_id`

## 4.2 Why not use Apple ID directly as the primary key
Directly using Apple account fields as the core data identifier is not ideal because:
- the app should remain independent from a single auth provider
- future support for email/login code/other auth methods becomes harder
- internal account migration and support operations become less flexible

## 4.3 Recommended data model
- `user_id` = primary key for product data
- `auth_provider = apple`
- `auth_provider_subject` = provider-specific user reference

This means:
- Apple ID helps users recover and continue their data
- product data still belongs to a platform-level `user_id`

---

## 5. Beta-to-production data inheritance

## 5.1 Goal
A beta user who upgrades to the production app should keep their identity and any account-linked capabilities without special migration friction.

## 5.2 Recommended strategy
From beta onward:
- assign each tester a stable `user_id`
- persist it locally and on the backend
- keep all usage accounting bound to that `user_id`

Production release then reuses the same identity layer.

## 5.3 What should inherit cleanly
At minimum:
- account identity
- quota state
- usage history
- user preferences
- provider mode selection

If full cloud sync is later added, then record content can also inherit by the same identity.

---

## 6. Privacy model

## 6.1 Default privacy stance
Default stance:
**all record content is stored locally on device unless the product explicitly asks the user to enable a cloud feature.**

This includes:
- raw records
- audio recordings
- transcripts
- cleaned text
- record-unit splits
- assistant-generated draft content

## 6.2 What may go to the server by default
Allowed server-side data by default:
- user/account identity
- device linkage metadata
- request type and usage statistics
- error telemetry without raw sensitive content
- optional anonymized aggregate metrics

## 6.3 What should not be uploaded silently
Without an explicit feature and user consent, do not upload by default:
- full record body text
- full transcript text
- audio files for permanent storage
- full assistant draft bodies for long-term storage

## 6.4 Admin capability boundary
Admin capability should focus on:
- user account state
- usage health
- quota state
- failure diagnostics
- anonymous aggregate trends

Admin access should **not** imply routine access to raw personal content.
If content-level debugging is ever needed, it should require a separate consented or explicitly authorized workflow.

---

## 7. Opening privacy statement

Recommended opening privacy statement:

> 我们重视你的隐私。默认情况下，你记录的内容只保存在你的本地设备上，包括文字记录、语音、转写和整理结果。我们不会默认把这些原始内容上传到服务器。只有当某项功能明确需要联网处理，或你未来主动开启同步/自带 API 等能力时，我们才会向你说明相应的数据使用方式。

This statement should appear early in onboarding or first-launch explanation.

---

## 8. Hosted API security

## 8.1 Principle
Provider API keys must never be shipped in the client app.
All hosted AI requests should flow through the platform backend proxy.

## 8.2 Required protections
The backend should provide:
- authenticated requests
- per-user quotas
- rate limiting
- request-type accounting
- abuse detection
- explicit over-limit errors

## 8.3 Request surface
The backend should expose product-level endpoints, not a general-purpose provider passthrough.
Examples:
- `/v1/atomize`
- `/v1/tags`
- `/v1/review`
- `/v1/focused-analysis`
- `/v1/transcribe`

This reduces the chance that users can repurpose the backend as an unrestricted AI proxy.

## 8.4 Why this matters for IPA / reverse engineering risk
Even if the app is unpacked or inspected:
- provider keys are not present in client code
- the backend still requires valid product authentication
- usage limits and endpoint restrictions remain enforceable server-side

---

## 9. Usage measurement during beta

## 9.1 Why usage data matters
Test users are valuable. The system should capture enough usage data to answer:
- which features are actually used
- where costs are concentrated
- where failure or confusion happens
- which testers need more quota or support

## 9.2 Minimum server-side usage model
Suggested entities:
- `user`
- `device`
- `usage_event`
- `daily_usage_rollup`

Suggested `usage_event` fields:
- `user_id`
- `device_id`
- `request_type`
- `created_at`
- `success`
- `estimated_tokens`
- `audio_seconds`
- `cost_units`

## 9.3 Product analytics vs. quota accounting
Two categories should be separated conceptually:
- product analytics
- quota/cost accounting

Quota accounting must be server-trusted.
Client analytics may support UX research but should not be the authoritative billing/limit source.

---

## 10. User-supplied AI API support

## 10.1 Goal
Users should have the option in the future to bring their own AI API key or provider account.

## 10.2 Recommended provider modes
- `hosted`
- `user_supplied`

The account or settings layer should track:
- `provider_mode`
- `provider_type`
- `credential_reference`

## 10.3 Protection requirements for user-supplied keys
User-supplied API credentials must be treated with the same seriousness as platform keys.
Requirements:
- never write raw keys into normal logs
- never include raw keys in debug export by default
- never expose raw keys in analytics payloads
- store them securely (device secure storage first; encrypted backend storage only if explicitly designed later)

## 10.4 Product boundary
Even when users supply their own AI provider:
- identity
- local records
- retrieval logic
- quotas for platform-hosted endpoints
can still remain under the app's normal product architecture.

User-supplied AI should plug into the AI execution layer, not replace account architecture.

---

## 11. Extract / export strategy

## 11.1 Principle
Data extractability should be preserved through structured intermediate layers.

## 11.2 Important structured objects already aligned with this goal
Examples include:
- record units
- tag hints
- hidden tag normalization mapping
- narrative material
- focused evidence bundles

## 11.3 Types of export to support over time
### User export
- records
- tags
- drafts
- review outputs
- optional audio references

### System extract
- structured AI input/output materials
- retrieval plans
- normalized hidden-tag mapping

### Admin / analytics export
- anonymous product usage summaries
- quota and request-type aggregates

## 11.4 Why this matters
Good extractability helps with:
- future migration
- backup
- cloud sync later
- user trust
- AI pipeline reuse

---

## 12. Recommended rollout order

### Stage 1
- stable `user_id`
- backend usage counting
- daily quota enforcement
- onboarding privacy statement

### Stage 2
- Sign in with Apple as an auth/recovery option
- user/device linkage
- clearer beta support operations

### Stage 3
- optional user-supplied AI provider mode
- export surfaces for users
- stronger admin usage dashboard

### Stage 4
- optional cloud sync / recovery for actual content
- only with explicit user consent and dedicated privacy design

---

## 13. Final decisions

### Decision 1
Use backend-issued `user_id` as the primary identity.

### Decision 2
Use Apple ID only as an authentication and recovery aid, not as the direct product data key.

### Decision 3
Keep record content local-first by default.

### Decision 4
Route hosted AI through backend proxy only.

### Decision 5
Support user-supplied AI later through provider-mode abstraction.

### Decision 6
Keep structured data extractable from the beginning.

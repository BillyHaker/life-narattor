---
name: feature-flags-governance
description: Rules for using feature flags safely (owner, purpose, expiry, cleanup).
version: 1.0
tags:
  - feature-flags
  - governance
---
# Feature Flags Governance

## Rules
- Every flag must have owner, purpose, default value, expiry/removal condition.
- Flags must be centralized in one place (FeatureFlags).
- Remove expired flags regularly.

## Acceptance
Flags are centralized and documented.

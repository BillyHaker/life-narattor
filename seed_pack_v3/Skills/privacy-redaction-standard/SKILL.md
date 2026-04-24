---
name: privacy-redaction-standard
description: Universal privacy & redaction rules for logs, exports, devtools, and AI prompts.
version: 1.0
tags:
  - privacy
  - security
  - redaction
---
# Privacy & Redaction Standard

## Data classes
- P0 secrets (keys/tokens/passwords): NEVER log/export
- P1 identifiers (email/phone/address): redact by default
- P2 user content: export only with explicit consent (internal builds)

## Acceptance
A redaction function is used by logging + diagnostics export + network recorder.

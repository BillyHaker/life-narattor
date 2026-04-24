---
name: contract-versioning
description: Versioning rules for DB/API/AI I/O contracts (compatibility + migration paths).
version: 1.0
tags:
  - contracts
  - versioning
  - api
  - db
---
# Contract Versioning

## Rules
- Every contract has a version label (e.g., clean_v1, assist_v1).
- Changes must specify compatibility: backward compatible or breaking.
- Breaking changes require ADR + migration + rollback.

## Acceptance
No unversioned contract shipped.

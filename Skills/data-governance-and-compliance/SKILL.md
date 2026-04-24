---
name: data-governance-and-compliance
description: Guidelines for data classification, retention, encryption and regulatory compliance; complements the privacy-redaction standard.
version: 1.0
tags:
  - data
  - governance
  - compliance
  - privacy
---
# Data Governance and Compliance

## Purpose
Provide universal guidelines for handling data beyond redaction, including retention policies, encryption, and adherence to legal frameworks (GDPR, CCPA, etc.).

## Guidelines

- **Data classification**: Use the categories defined in `privacy-redaction-standard` (P0, P1, P2) to classify all data. Document classification in project docs.
- **Retention policies**: Define retention periods for each data class. For example, logs containing P1 data should be retained no longer than 30 days; P2 data should be purged as soon as the session ends.
- **Encryption**: All stored data and in-transit data must be encrypted using industry‑standard protocols (e.g., TLS 1.3, AES‑256). Encryption keys must be rotated and access controlled.
- **Consent and lawful basis**: Identify the lawful basis for collecting P2 data and ensure user consent is obtained where required.
- **Regulatory mapping**: For each jurisdiction in which the project operates, map applicable regulations (GDPR, CCPA) to specific controls. Document compliance steps in Docs/06_Testing or 05_Changes.

## Acceptance
A project meets this skill when:

- Data classification and retention policies are documented.
- Encryption is applied consistently across storage and transport.
- Compliance requirements are identified and tracked.
- No retention of user data beyond the defined period is allowed.
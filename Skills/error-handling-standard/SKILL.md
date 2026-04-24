---
name: error-handling-standard
description: Universal guidelines for handling errors, retries and fallback behaviour across UI, network and AI components.
version: 1.0
tags:
  - error-handling
  - resilience
  - reliability
---
# Error Handling Standard

## Purpose

Provide a consistent approach to detecting, surfacing and recovering from errors in any application.  Robust error handling improves reliability and user trust.

## Guidelines

### Classification
- **Recoverable errors:** transient issues that can be retried (e.g., network timeouts, rate limits).  Implement automatic retries with exponential backoff and a maximum attempt limit.
- **User‑action errors:** issues that require user intervention (e.g., invalid input, missing permissions).  Display clear, actionable messages and guide the user to resolution.
- **Fatal errors:** issues that cannot be recovered in the current context (e.g., corrupted state, unsupported device).  Fail gracefully, log the incident, and guide the user to contact support or retry later.

### Logging and monitoring
- Log error details (without sensitive data) including stack traces, request identifiers and context to aid debugging.
- Use the `privacy-redaction-standard` to ensure P0/P1/P2 data is redacted【973127148288370†L12-L16】.
- Emit alerts for repeated fatal errors or spikes in recoverable errors so that the team can act promptly.

### User experience
- Use language appropriate to the end user; avoid technical jargon.
- Offer meaningful retry or refresh actions when possible.
- For asynchronous tasks (e.g., AI requests), provide progress indicators and allow cancellation.
- Ensure error messages are accessible (screen reader friendly, sufficient contrast).  See the `accessibility-guidelines` skill.

### Acceptance
- All network and AI calls include retry logic for recoverable errors.
- User‑facing screens handle empty, loading and error states gracefully.
- Error logs are anonymised and redact sensitive information in accordance with the privacy standard.
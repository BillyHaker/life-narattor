---
name: devtools-debug-suite
description: Universal dev tools for mobile and web: debug-only UI, feature flags, and diagnostics export; minimal production impact across platforms.
version: 1.1
platforms:
  - ios
  - android
  - web
tags:
  - devtools
  - debugging
  - cross-platform
  - mobile
  - web
---
# DevTools Debug Suite (Cross‑Platform)

## Default policy

Across all platforms, debug tools must be *opt‑in* in production builds.  During development and testing, they should be clearly accessible and triggerable without interfering with user flows.

| Platform | Debug build behaviour | Release build behaviour | Recommended activation mechanism |
|---------|-----------------------|-------------------------|-----------------------------------|
| iOS     | Dev menu visible by default | Excluded entirely | Shake gesture, triple‑tap with developer credentials |
| Android | Dev menu visible by default | Excluded entirely | Shake gesture or secret tap area |
| Web     | Debug overlay available at `?debug=true` | Disabled by default | Query parameter, dev subdomain |

## Required modules

Each platform must provide a consistent set of debug modules:

- App info panel (version, build, environment)
- Feature flags toggling (read from `feature-flags-governance`)
- Logs (ring buffer) + export (must apply `privacy-redaction-standard`)
- Diagnostics export (zip, redacted) including environment variables, configuration, user path; ensure secrets removed
- Network inspector (optional) to view API requests and responses (must respect privacy redaction)

## Privacy & redaction

All debug modules must enforce the `privacy-redaction-standard`.  P0 secrets must never be recorded; P1 identifiers should be redacted by default; and P2 user data may only be exported when the build is internal or with explicit user consent.  This requirement applies equally across iOS, Android and web environments.

## Acceptance

- There is a single injection point in the application code to attach the debug suite, guarded by platform‑specific debug flags (e.g., `#if DEBUG` in Swift/Kotlin or environment check in JavaScript).
- Required modules are implemented and accessible behind an activation gesture or flag.
- User secrets are properly redacted in logs and diagnostics.
- The debug suite does not ship or run in production builds unless explicitly enabled for internal builds.

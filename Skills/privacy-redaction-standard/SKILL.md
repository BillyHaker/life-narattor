---
name: privacy-redaction-standard
description: Universal privacy & redaction rules for logs, exports, devtools, and AI prompts.
version: 1.1
tags:
  - privacy
  - security
  - redaction
changelog:
  - "v1.0: initial (data classes only)"
  - "v1.1 (2026-03-06): added concrete redaction patterns, implementation contract, test cases — aligned with AIDebugStore.swift implementation"
---

# Privacy & Redaction Standard

## Data classes

| Class | Examples | Default handling |
|-------|----------|-----------------|
| **P0 secrets** | API keys (`sk-…`), Bearer tokens, passwords | NEVER log or export — always redact |
| **P1 identifiers** | email, phone, address, username | Redact by default in logs; may appear in UI with consent |
| **P2 user content** | capture text, atom content, clean text | Export only with explicit user consent (internal/debug builds only) |

## Where redaction applies

- **Debug logs** — any string passed to `AIDebugStore` / `LogStore`
- **Diagnostics export** — before writing to file or clipboard
- **Network recorder** — request/response bodies
- **AI prompt construction** — never embed P0 secrets in any debug-visible string

## Required redaction patterns (V1)

All five patterns must be applied by `AIDebugRedactor.redact(_ input: String) -> String`:

```
// P0-1: OpenAI-style API keys (sk-xxxxx...)
Pattern:     sk-[A-Za-z0-9]{10,}
Replacement: sk-***REDACTED***

// P0-2: Bearer tokens in Authorization headers
Pattern:     Bearer [A-Za-z0-9\-_=+/.]+
Replacement: Bearer ***REDACTED***

// P0-3: api_key / apikey in JSON bodies (case-insensitive key=value or key:"value")
Pattern:     (api[_-]?key["']?\s*[:=]\s*["']?)[^\s,\"'}]+
Replacement: <api_key_field>***REDACTED***

// P1-1: Email addresses
Pattern:     [A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}
Replacement: ***@***.***

// P2: Long user content — truncate to 100 chars to prevent bulk exposure
If input.count > 100: return first 100 chars + "…[TRUNCATED]"
```

> **Order matters**: Apply P0 patterns before P2 truncation.

## Implementation contract

```swift
struct AIDebugRedactor {
    /// Must be called on every string before logging or export.
    static func redact(_ input: String) -> String
}
```

- Pure function (no side effects, no networking).
- Fast — called synchronously on every log write.
- Used by: `AIDebugStore`, `DiagnosticsExporter`, and any future `NetworkRecorder`.

## Acceptance criteria

1. `AIDebugRedactor.redact()` is used by **all** logging and diagnostics export paths.
2. No P0 secret appears verbatim in any log, debug view, or exported file.
3. P1 identifiers (emails) do not appear in logs unless explicitly tagged as safe.
4. P2 user content is truncated or omitted from exported diagnostics unless in a debug build with explicit consent.

## Test cases (minimum — required before shipping)

| Input | Expected output |
|-------|----------------|
| `"sk-abc123XYZABC"` | contains `"sk-***REDACTED***"` |
| `"Bearer eyJhbGciOiJIUzI1NiJ9.xyz"` | contains `"Bearer ***REDACTED***"` |
| `{"api_key": "my-secret-key"}` | does NOT contain `"my-secret-key"` |
| `"user@example.com"` | contains `"***@***.***"` |
| Any string ≥ 150 chars | length ≤ 110 chars (100 + "[TRUNCATED]") |

## Cross-references

- Implementation: `Life Narattor/DevTools/AIDebugStore.swift` — `AIDebugRedactor`
- Decision record: `Docs/03_Decisions/ADR-001-privacy-redaction-architecture.md`
- Applied in: `DevTools/DiagnosticsExporter.swift`, `DevTools/AIDebugStore.swift`

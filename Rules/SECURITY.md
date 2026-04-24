# SECURITY (Universal)

Security is everyone’s responsibility.  Follow these guidelines to protect user data and maintain trust.

- **Never commit secrets** – Keys, tokens and passwords must never be committed to source control.  Use secure secret management.
- **Validate and sanitise inputs** – Always validate and sanitise all external inputs (user input, network responses, file contents) to prevent injection attacks or misuse.
- **Avoid leaking sensitive data in errors** – Do not include confidential information in error messages.  Show generic messages to users and log detailed information in secure logs.
- **Logs/exports must redact sensitive data** – Apply the `privacy-redaction-standard` to all logs and diagnostics exports.  Remove or obfuscate P0 secrets, and redact P1 identifiers by default.
- **Prefer least-privilege integrations** – Grant only the permissions needed for each integration or API call.  Rotate tokens regularly.
- **Secure transport and storage** – Use encrypted channels (e.g. TLS) for all network communications.  Encrypt sensitive data at rest where required.
- **Diagnostics export redaction** – For diagnostics export, redact authentication headers, tokens and personal identifiers by default.  Only include P2 user data with explicit consent.

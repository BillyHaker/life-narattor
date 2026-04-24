---
name: internationalization-guidelines
description: Universal guidelines for preparing projects for multiple languages, locales and cultural contexts.
version: 1.0
tags:
  - i18n
  - l10n
  - localization
  - global
---
# Internationalization Guidelines

## Purpose
Ensure that projects generated from this seed pack are ready to support multiple languages and cultural contexts without refactoring core logic.

## Guidelines

- **Separation of content**: Do not hard‑code user‑facing strings in code. Use resource files or translation dictionaries.
- **Locale handling**: Handle date, time, number and currency formats using locale‑aware APIs.
- **Bidirectional text**: Support both left‑to‑right (LTR) and right‑to‑left (RTL) layouts where applicable.
- **Flexible layouts**: Avoid fixed widths for UI elements; accommodate longer text in languages like German or languages with different word breaks such as Chinese.
- **Language negotiation**: Detect and respect the user’s language preference, with a sensible default and a manual override in settings.
- **Cultural sensitivity**: Avoid idioms, metaphors and images that may not translate well. Consider local holidays and cultural norms in scenarios and sample data.

## Acceptance
A project meets this skill when:

- All strings are externalized and available for translation.
- The UI correctly formats dates, times and numbers according to the user’s locale.
- The design works for both LTR and RTL languages.
- Language preference can be changed without restarting the app.
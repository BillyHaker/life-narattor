# Beta Review Notes

## App purpose
Life Narattor is a personal recording app that helps users capture notes, voice memos, assistant conversations, and AI-based review summaries.

## Privacy boundary
- Record content is stored locally on device by default.
- The app does not expose upstream provider API keys to end users.
- AI features that require network processing go through the product backend proxy.

## Current beta scope
- Text records
- Voice capture and transcription
- Assistant conversation
- Assistant conversation -> draft record -> confirm before save
- AI Review as the primary review entry

## Hidden / not exposed in this beta
- Weekly/monthly automatic review entry points remain hidden.
- Dev tools are not intended for tester-visible use.
- Long-form narrative generation and bring-your-own-API are not part of this beta.

## Reviewer note
If review requires entering the beta administration site, use the locally configured admin route and token in the backend environment. End users do not need access to backend credentials.

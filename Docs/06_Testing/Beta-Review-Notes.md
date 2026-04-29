# Beta Review Notes

## App purpose
Life Narattor is a personal recording app that helps users capture notes, voice memos, assistant conversations, and AI-based review summaries.

## Privacy boundary
- Record content is stored locally on device by default.
- Before entering the app, users must review and accept the in-app “Privacy and AI Processing” disclosure.
- AI features that require network processing go through the product backend proxy.
- Data sent for AI processing may include record text, user questions, related snippets, draft text, and audio needed for transcription.
- Current third-party AI service providers are OpenAI and Volcano Engine/Doubao for speech transcription.
- The app does not expose upstream provider API keys to end users.

## Current beta scope
- Text records
- Voice capture and transcription
- Assistant conversation
- Assistant conversation -> draft record -> confirm before save
- AI Review as the primary review entry
- Timeline review for Today / 7 days / 30 days

## Hidden / not exposed in this beta
- Legacy weekly/monthly calendar review entry points remain hidden.
- Debug/Dev tools are only compiled into debug builds and are not tester-visible in TestFlight / Release.
- Long-form narrative generation and bring-your-own-API are not part of this beta.

## Reviewer note
If review requires entering the beta administration site, use the locally configured admin route and token in the backend environment. End users do not need access to backend credentials.

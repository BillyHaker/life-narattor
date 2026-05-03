# ADR-015 - Onboarding and Custom Bottom Navigation

## Metadata
- Date: 2026-05-03
- Owner: Codex
- Scope: UX/UI
- Status: Accepted
- Related skills: None

## Context
The App Store build exposed two first-run usability issues: the app lacked a concise product guide, and the native bottom tab bar looked small and cramped on large iPhones. The app also needs to keep the production surface simple by hiding developer-only navigation.

## Alternatives
- Keep the native `TabView` tab bar and only adjust labels. This is low risk but does not solve the cramped visual weight or production Dev exposure cleanly.
- Add a separate help screen but keep first launch unchanged. This avoids interruption, but new users still do not learn the three core workflows at the moment they need it.
- Use a custom root shell with a larger three-item navigation bar and a short first-run product guide.

## Decision
Use a custom three-item root bottom navigation for Record, Timeline, and AI Review. Show a short first-run onboarding guide after privacy consent and before the main app. Keep the guide accessible from Settings.

## Rationale
- The app has only three production destinations, so a larger custom bar is clearer and less cramped than the native five-item tab layout.
- First-run onboarding can explain the app's AI-native workflow without turning the product into a settings-heavy traditional app.
- Lazy-loading tabs avoids creating hidden Timeline or AI Review views before the user visits them, reducing unintended background work and AI cost.

## Consequences
- The app no longer uses native `TabView` for root navigation, so custom accessibility and hit target behavior must be maintained carefully.
- Dev tooling remains in code but is not exposed from the production root navigation.
- New users see one additional guide after privacy consent, but can skip it.

## Validation
- Xcode build must pass.
- First launch after privacy consent should show the onboarding guide.
- Completing or skipping the guide should enter the main app and persist via `app.hasSeenProductGuide`.
- Settings should allow replaying the guide.
- Switching root tabs should preserve visited tab state without loading unvisited tabs.

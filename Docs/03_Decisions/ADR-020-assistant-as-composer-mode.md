# ADR-020 - Assistant as Composer Mode

## Metadata
- Date: 2026-05-08
- Owner: Codex
- Scope: iOS/Record UX
- Status: Accepted
- Related session: [2026-05-08 Session 004](../04_Sessions/2026-05-08_session-004.md)
- Related change: [Change 239](../05_Changes/Change-239-record-composer-bottom-bar.md)

## Context
The Record screen previously placed a `记录 / 助手` segmented control directly above the text composer, while the app-level root tab bar sat below it. This created two bottom navigation layers competing for attention, especially on large iPhones where the controls still appeared visually small and crowded.

The product direction is lightweight capture: the user should feel they can record a sentence quickly, while Assistant is available when they need help organizing a thought.

## Alternatives
- Keep the full segmented control and only increase spacing.
- Move Assistant to a separate tab.
- Treat Assistant as a composer mode within the Record screen.

## Decision
Treat Assistant as an inline composer mode. The root tab bar remains the only bottom page navigation. The composer exposes Assistant as a lightweight mode button next to the text field.

## Rationale
- Reduces visual hierarchy conflict at the bottom of the screen.
- Keeps ordinary capture as the primary path.
- Makes Assistant feel like a way to handle the current input, not a separate destination competing with Record.
- Preserves existing routing through `CaptureInputMode` and `FeedSurface` without changing persistence or AI flows.

## Consequences
- Users switch Assistant from inside the composer instead of a full segmented switch.
- Assistant mode needs clear visual feedback and placeholder copy.
- Future composer modes should follow the same lightweight control pattern rather than adding another bottom navigation layer.

## Validation
- Debug simulator build passed.
- Manual verification remains tracked in `VRF-043` because simulator test execution was blocked by CoreSimulatorService availability.

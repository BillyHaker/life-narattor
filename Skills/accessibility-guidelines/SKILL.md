---
name: accessibility-guidelines
description: Universal accessibility guidelines to ensure user interfaces are inclusive and usable by people of all abilities.
version: 1.0
tags:
  - accessibility
  - a11y
  - ui
---
# Accessibility Guidelines

## Purpose

Establish baseline accessibility requirements for any application produced with this seed pack.  Following these guidelines helps ensure compliance with international standards (e.g., WCAG) and improves usability for everyone.

## Guidelines

### Visual design
- **Contrast:** Text and interactive elements must meet minimum contrast ratios (4.5:1 for normal text, 3:1 for large text).  Do not rely on color alone to convey meaning.
- **Font size:** Use a base font size of at least 16 pt; support dynamic type on platforms that offer it.
- **Touch targets:** Ensure tappable areas are at least 44 × 44 pt on mobile to accommodate users with limited dexterity.

### Structure and semantics
- Provide semantic labels for all controls and images (e.g., using accessibilityLabel / aria-label).
- Use native components where possible so that assistive technologies convey the correct role (e.g., buttons vs. custom views).
- Maintain logical navigation order; avoid placing hidden interactive elements off the screen.

### Interaction
- Support keyboard navigation on desktop (tab order, focus indicators).
- Avoid relying solely on gestures; provide alternative controls for actions like swipe or shake.
- Announce dynamic updates (e.g., loading, completion) to screen readers using appropriate accessibility notifications.

### Media
- Provide captions and transcripts for audio and video content.
- Ensure images that convey information include alternative text.

### Acceptance
- All new screens are evaluated against these guidelines.
- Automated a11y checkers (e.g., WAVE, axe) show no critical violations.
- Manual testing verifies usability with screen readers and without a mouse.
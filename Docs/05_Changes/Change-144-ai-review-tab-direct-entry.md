# Change 144 - AI review tab direct entry

## What changed
- Switched the main tab from `ReviewHomeScreen` to a direct `SearchScreen()` entry.
- Kept the review experience focused on manual-input AI review.
- Removed weekly/monthly review pages from the main user path without deleting the screens.

## Why
- Weekly/monthly review currently caused confusion and UI issues.
- The current product direction is to use a single ChatGPT-like AI review surface and require explicit user input before retrieval.

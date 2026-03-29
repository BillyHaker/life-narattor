# Change-182 GitHub Pages Privacy and Support Site

## Summary
- Added a minimal static site for App Store submission URLs.
- Added a privacy policy page and a support page under `site/`.
- Added a GitHub Pages deployment workflow.

## Files Changed
- `.github/workflows/pages.yml`
- `site/index.html`
- `site/privacy/index.html`
- `site/support/index.html`
- `Docs/04_Sessions/2026-03-29_session-001.md`

## User-Visible Impact
- The repository now contains public-facing pages suitable for the App Privacy URL and Support URL fields in App Store Connect.

## Verification Steps
1. Inspect the static pages locally under `site/`.
2. Confirm the workflow file exists at `.github/workflows/pages.yml`.
3. After pushing to GitHub and enabling Pages, verify these URLs:
   - `/privacy/`
   - `/support/`

## Rollback Notes
- Delete the `site/` directory and `.github/workflows/pages.yml`.
- Revert the session log entry if needed.

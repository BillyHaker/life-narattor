# Change-066 — Local Proxy Launchd Management And Env Safety

## Meta
- Date: 2026-03-08
- Owner: Codex (GPT-5)
- Scope: Server/DevOps/Security
- Related Skills: dev-logging-system, error-handling-standard
- Related ADRs: None
- Status: Done

## What changed
- Improved local startup script portability:
  - `server/run_local_proxy.sh` now uses script-relative path and PATH-based Node discovery.
  - Added explicit `.env` and Node preflight checks.
- Added reusable local service manager:
  - `server/manage_launchd_proxy.sh` with `install/start/stop/restart/status/logs/uninstall`.
- Updated docs:
  - `server/README.md` now includes one-shot startup + launchd keep-alive workflow.
- Added secret safety:
  - `.gitignore` now ignores `server/.env`.

## Files Changed
- `.gitignore`
- `server/run_local_proxy.sh`
- `server/manage_launchd_proxy.sh`
- `server/README.md`
- `Docs/04_Sessions/2026-03-08_session-019.md`
- `Docs/05_Changes/Change-066-local-proxy-launchd-management-and-env-safety.md`

## Contracts/DB changes
- None.

## User-visible impact
- Development workflow is more stable:
  - backend can be managed consistently via script commands.
  - machine-specific path assumptions removed.
- Reduced risk of committing local API secrets.

## Verification Steps
1. Script syntax:
   - `zsh -n server/run_local_proxy.sh`
   - `zsh -n server/manage_launchd_proxy.sh`
2. Service health:
   - `cd server && ./manage_launchd_proxy.sh status`
   - Expected: launchd state running + `/healthz` returns `{"status":"ok"}`
3. Server syntax gate:
   - `node --check server/server.js`

## Rollback Notes
- Revert files listed in `Files Changed`.

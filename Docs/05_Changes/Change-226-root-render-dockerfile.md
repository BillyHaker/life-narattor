# Change-226: Root Render Dockerfile

## Summary
Added a repository-root Dockerfile so Render can build the backend without requiring a `Root Directory` override.

## Files Changed
- `Dockerfile`
- `Docs/04_Sessions/2026-05-02_session-006.md`
- `Docs/05_Changes/Change-226-root-render-dockerfile.md`

## Behavior
- Render can use default Dockerfile discovery from the repository root.
- The container still runs the existing Node backend from `server/server.js`.
- This reduces deployment form friction and avoids misconfigured root directory values.

## Verification
- JS syntax checks passed.
- `git diff --check` passed.
- Local Docker build was skipped because Docker is not installed/available in this environment.

## Manual Verification Backlog
- Deploy the Render service with root directory empty and confirm `/healthz` returns 200.

## Rollback Notes
- Remove the root `Dockerfile`; continue using `server/Dockerfile` with Render root directory set to `server`.

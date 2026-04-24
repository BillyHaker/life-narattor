# Change 110 - Backend Atomize Routed To AI Proxy

## What Changed
- Added `/v1/atomize` to the Node proxy.
- Implemented server-side atomize schema and OpenAI call for structured atom generation.
- Replaced `BackendAIService.atomize(...)` local punctuation splitting with a real POST to `/v1/atomize`.
- Added `AtomizeRequest` / `AtomizePolicy` request types in the app client.

## Why
The app had already moved toward AI-only splitting, but the backend service path still used the old local split stub. That mismatch made splitting behavior inconsistent and made the UI appear stuck in unsplit states despite available network.

## Files Changed
- server/server.js
- Life Narattor/AI/AIService.swift

## Verification Steps
- `node --check server/server.js`
- Inspect `BackendAIService.atomize(...)` to confirm it posts to `/v1/atomize`

## Rollback Notes
- Revert `BackendAIService.atomize(...)` to the old local stub if proxy atomization needs to be disabled.
- Remove `/v1/atomize` server handling if reverting proxy support.

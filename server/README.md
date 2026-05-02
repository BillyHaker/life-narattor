# Life Narrator AI Proxy (Minimal)

This server keeps upstream AI provider keys off-device and enforces basic protections.

## Why
- Client-embedded API keys are unsafe and easily extracted.
- A proxy enables App Review access while controlling usage.

## Setup
1) Install Node.js 18+ (fetch built-in).
2) Copy `.env.example` to `.env` and set values.
3) Run:
   - one-shot foreground: `./run_local_proxy.sh`
   - or direct: `node server.js`

## Environment
- `OPENAI_API_KEY` (required)
- `OPENAI_BASE` (optional, default `https://api.openai.com/v1/responses`)
- `OPENAI_AUDIO_BASE` (optional, default `https://api.openai.com/v1/audio/transcriptions`)
- `TRANSCRIBE_PROVIDER` (optional, `openai` or `doubao`, default `doubao`)
- `PORT` (optional, default `8787`)

### Doubao ASR (default transcription provider)
- `DOUBAO_ASR_URL` (required, set from Volcengine endpoint)
- `DOUBAO_APP_ID` (required)
- `DOUBAO_ACCESS_TOKEN` (required)
- `DOUBAO_RESOURCE_ID` (optional, default `volc.bigasr.auc_turbo`)
- `DOUBAO_MODEL_NAME` (optional, default `bigmodel`)

### Model routing
- `MODEL_QUICK` — QuickAck model (default `gpt-4o-mini`)
- `MODEL_ASSIST` — Assist model (default `gpt-4o-mini`)
- `MODEL_DEEP` — DeepTask model (default `gpt-4o-mini`)

### Protection controls
- `ALLOWED_TOKENS` — comma-separated bearer tokens allowed to call the proxy
- `REVIEW_WHITELIST` — comma-separated reviewer user ids, treated as `reviewer` tier
- `RATE_LIMIT_RPM` — requests per minute per user/token (default 30)

### Usage tiers and quotas
- `USAGE_STORE_PATH` — path for the local usage store. If unset, the server uses the system temp directory.
- `USAGE_DEFAULT_TIER` — default tier for public users. Supported values: `free`, `pro`, `reviewer`. Default: `free`.
- `USAGE_PRO_USER_IDS` — comma-separated user ids with `pro` limits.
- `USAGE_REVIEWER_USER_IDS` — comma-separated user ids with `reviewer` limits.
- `USAGE_TIER_OVERRIDES` — JSON object for explicit user tier mapping, for example `{ "user_a": "pro", "user_b": "reviewer" }`.
- `USAGE_LIMIT_OVERRIDES` — JSON object for emergency quota tuning without redeploying code. You can override by tier and request type, for example `{ "free": { "chat": 8, "transcription": { "daily": 180, "kind": "seconds" } } }`.

Default tier behavior:
- `free` keeps records, cleaning, atomization, light review, and limited assistant use available while controlling cost.
- `pro` raises daily limits for assistant, review, and transcription.
- `reviewer` is intended for App Review or trusted testers so they are not blocked during validation.

Current `free` daily limits:
- Assistant chat: 12
- Conversation-to-record archive: 3
- AI review overview/focused/follow-up: 4 / 4 / 6
- Transcription: 300 seconds
- Record processing internals: quick ack 60, clean 40, atomize 40, tag suggestions 40

The admin dashboard shows request totals, quota hits, tier usage, per-user tier, model/provider, and estimated input tokens.

### User-provided API keys
The current public build still routes managed AI through this backend. User-provided AI or transcription APIs are reserved for a later setting and should remain OpenAI-compatible with the app's existing JSON-schema request contract before being exposed.

## Request headers expected
- `Authorization: Bearer <token>` (optional unless `ALLOWED_TOKENS` set)
- `X-User-Id` (optional; used for quota buckets)
- `X-App-Id` / `X-App-Version` (sent by client for logging)

## Endpoints
- `POST /v1/quick/ack`
- `POST /v1/assist`
- `POST /v1/tasks` (returns stub ID)
- `POST /v1/transcribe` (provider-routed, returns `{ "text": "..." }`)
- `GET /healthz`

## Local keep-alive (macOS launchd)
Use the helper script:

- Install/update and start:
  - `./manage_launchd_proxy.sh install`
- Check status:
  - `./manage_launchd_proxy.sh status`
- Restart after editing `.env`:
  - `./manage_launchd_proxy.sh restart`
- Stop:
  - `./manage_launchd_proxy.sh stop`
- Logs:
  - `./manage_launchd_proxy.sh logs`
- Uninstall launch agent:
  - `./manage_launchd_proxy.sh uninstall`

## Notes
- This is a minimal example; replace in-memory limits with Redis or database for production.
- Add monitoring/alerts for abuse and cost spikes.
- iOS client API contract does not change; provider switching is server-side only.

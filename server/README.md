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
- `DOUBAO_API_KEY` (preferred for newer Volcengine/Doubao console credentials)
- `DOUBAO_APP_ID` + `DOUBAO_ACCESS_TOKEN` (legacy credential pair; used when `DOUBAO_API_KEY` is empty)
- `DOUBAO_RESOURCE_ID` (optional, default `volc.bigasr.auc_turbo`)
- `DOUBAO_MODEL_NAME` (optional, default `bigmodel`)
- `DOUBAO_USER_ID` (optional, default `life-narrator`; sent as the ASR user uid)

When `TRANSCRIBE_PROVIDER=doubao`, the server will try Doubao first. If Doubao returns a provider configuration/authentication error and `OPENAI_API_KEY` is configured, the server falls back to OpenAI audio transcription so the production app does not become fully blocked by a Doubao credential issue.

### Model routing
- `MODEL_QUICK` — QuickAck model (default `gpt-4o-mini`)
- `MODEL_ASSIST` — Assist model (default `gpt-4o-mini`)
- `MODEL_DEEP` — DeepTask model (default `gpt-4o-mini`)

### Protection controls
- `ALLOWED_TOKENS` — comma-separated bearer tokens allowed to call the proxy
- `REVIEW_WHITELIST` — comma-separated reviewer user ids, treated as `reviewer` tier
- `RATE_LIMIT_RPM` — requests per minute per user/token (default 30)

### Feedback
- `FEEDBACK_STORE_PATH` — JSONL path for in-app feedback. If unset, the server uses the system temp directory.
- `FEEDBACK_MAX_BYTES` — maximum feedback request size, including optional screenshot base64 (default `5000000`).

### Usage tiers and quotas
- `USAGE_STORE_PATH` — path for the local usage store. If unset, the server uses the system temp directory.
- `USAGE_DEFAULT_TIER` — default tier for public users. Supported values: `free`, `reviewer`, and internal override tiers `trial`, `daily`, `deep`. Default: `free`.
- `USAGE_TRIAL_DAYS` — internal trial override length in days. Default: `7`. The current public app does not automatically start users on a trial tier.
- `USAGE_DAILY_USER_IDS` — comma-separated user ids with an internal higher-limit tier. Reserved for manual testing; not an active paid plan.
- `USAGE_DEEP_USER_IDS` — comma-separated user ids with an internal higher-limit tier. Reserved for manual testing; not an active paid plan.
- `USAGE_PRO_USER_IDS` — legacy alias treated as `deep`.
- `USAGE_REVIEWER_USER_IDS` — comma-separated user ids with `reviewer` limits.
- `USAGE_TIER_OVERRIDES` — JSON object for explicit user tier mapping, for example `{ "user_a": "free", "reviewer_a": "reviewer" }`.
- `USAGE_CREDIT_LIMIT_OVERRIDES` — JSON object for emergency monthly credit tuning without redeploying code, for example `{ "free": 250 }`.
- `USAGE_CREDIT_COST_OVERRIDES` — JSON object for emergency per-request credit tuning, for example `{ "chat": 4, "transcription": { "creditsPerMinute": 12, "minimumCredits": 1 } }`.

Default tier behavior:
- `free` is the current public default and gives 300 AI credits per month while keeping local recording free.
- `trial` remains available only as an internal override. It gives 7 days with a 700-credit pool, then automatically falls back to `free`.
- `daily` and `deep` remain available only as internal higher-limit overrides. They are not exposed as active paid subscription plans.
- `reviewer` is intended for App Review or trusted testers so they are not blocked during validation.

Default credit costs:
- Quick acknowledgement: 0
- Clean transcript: 1
- Atomize record: 1
- Hidden/implicit tag suggestions: 1
- Assistant chat: 3
- Conversation-to-record archive: 8
- AI review: 5
- AI review follow-up: 3
- Transcription: 10 credits per minute
- Hidden tag monthly clustering or normalization: 20

The admin dashboard shows request totals, credit usage, quota hits, tier usage, per-user tier, model/provider, and estimated input tokens.

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
- `POST /v1/feedback` (stores user-submitted feedback, contact info, device info, and optional screenshot)
- `GET /healthz`

## Public deployment
The App Store build needs a public HTTPS URL for this server. Recommended first deployment shape:

1. Create a small Node service on Render, Railway, Fly.io, or another HTTPS host.
2. Use `server/Dockerfile` or run `npm start` from the `server/` directory.
3. Configure provider keys and persistent store paths as environment variables.
4. Leave `ALLOWED_TOKENS` empty for the first public build unless the app is also configured with a client token. User-level cost control is enforced by `X-User-Id` quotas.
5. After deployment, open `https://<your-host>/healthz` and confirm `{ "status": "ok" }`.
6. Put the resulting HTTPS URL into `Life Narattor/AppConfig.plist` as `AIBaseURL` before archiving. The app also supports the `LifeNarratorAIBaseURL` Info.plist key if you configure it through Xcode build settings.

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

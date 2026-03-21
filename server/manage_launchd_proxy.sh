#!/bin/zsh
set -euo pipefail

LABEL="com.lifenarrator.ai-proxy"
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PLIST_PATH="$HOME/Library/LaunchAgents/${LABEL}.plist"
LAUNCHD_DOMAIN="gui/$(id -u)"
OUT_LOG="/tmp/lifenarrator_launchd.out.log"
ERR_LOG="/tmp/lifenarrator_launchd.err.log"

require_env_file() {
  if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "Missing .env in $SCRIPT_DIR. Copy .env.example to .env first."
    exit 1
  fi
}

require_node() {
  NODE_BIN="${NODE_BIN:-$(command -v node || true)}"
  if [ -z "$NODE_BIN" ]; then
    echo "Node.js not found in PATH. Install Node.js 18+ and retry."
    exit 1
  fi
}

write_plist() {
  require_env_file
  require_node

  mkdir -p "$HOME/Library/LaunchAgents"

  local server_path="${SCRIPT_DIR}/server.js"
  local escaped_home="${(q)HOME}"
  local command="exec '${NODE_BIN}' '${server_path}'"
  local -a env_keys=(
    PORT
    OPENAI_API_KEY
    OPENAI_BASE
    OPENAI_AUDIO_BASE
    TRANSCRIBE_PROVIDER
    DOUBAO_ASR_URL
    DOUBAO_APP_ID
    DOUBAO_ACCESS_TOKEN
    DOUBAO_RESOURCE_ID
    DOUBAO_MODEL_NAME
    MODEL_QUICK
    MODEL_ASSIST
    MODEL_DEEP
    ALLOWED_TOKENS
    REVIEW_WHITELIST
    RATE_LIMIT_RPM
    ADMIN_TOKEN
    RESEND_API_KEY
    INVITE_EMAIL_FROM
    INVITE_EMAIL_REPLY_TO
  )
  local env_xml=""

  set -a
  source "$SCRIPT_DIR/.env"
  set +a

  for key in "${env_keys[@]}"; do
    local value="${(P)key:-}"
    if [ -n "$value" ]; then
      env_xml="${env_xml}
  <key>${key}</key>
  <string>${value}</string>"
    fi
  done

  cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>${command}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>EnvironmentVariables</key>
  <dict>${env_xml}
  </dict>
  <key>WorkingDirectory</key>
  <string>${escaped_home}</string>
  <key>StandardOutPath</key>
  <string>${OUT_LOG}</string>
  <key>StandardErrorPath</key>
  <string>${ERR_LOG}</string>
</dict>
</plist>
EOF
}

install_service() {
  write_plist
  : > "$OUT_LOG"
  : > "$ERR_LOG"
  launchctl bootout "${LAUNCHD_DOMAIN}/${LABEL}" >/dev/null 2>&1 || true
  launchctl bootstrap "${LAUNCHD_DOMAIN}" "$PLIST_PATH"
  launchctl kickstart -k "${LAUNCHD_DOMAIN}/${LABEL}"
  status_service
}

start_service() {
  if [ ! -f "$PLIST_PATH" ]; then
    install_service
    return
  fi

  launchctl bootstrap "${LAUNCHD_DOMAIN}" "$PLIST_PATH" >/dev/null 2>&1 || true
  launchctl kickstart -k "${LAUNCHD_DOMAIN}/${LABEL}"
  status_service
}

stop_service() {
  launchctl bootout "${LAUNCHD_DOMAIN}/${LABEL}" >/dev/null 2>&1 || true
  echo "Stopped ${LABEL}"
}

restart_service() {
  stop_service
  start_service
}

status_service() {
  launchctl print "${LAUNCHD_DOMAIN}/${LABEL}" 2>/dev/null | rg "state =|pid =|last exit code =" || true
  curl -s -m 2 "http://127.0.0.1:8787/healthz" || true
  echo
}

logs_service() {
  echo "--- ${OUT_LOG} ---"
  tail -n 80 "$OUT_LOG" 2>/dev/null || true
  echo "--- ${ERR_LOG} ---"
  tail -n 80 "$ERR_LOG" 2>/dev/null || true
}

uninstall_service() {
  stop_service
  rm -f "$PLIST_PATH"
  echo "Removed $PLIST_PATH"
}

usage() {
  cat <<EOF
Usage: ./manage_launchd_proxy.sh <command>

Commands:
  install    Install/update launchd agent and start service
  start      Start service (installs first if needed)
  stop       Stop service
  restart    Restart service
  status     Show launchd state + /healthz
  logs       Tail launchd logs
  uninstall  Stop service and remove launchd plist
EOF
}

main() {
  local cmd="${1:-status}"
  case "$cmd" in
    install) install_service ;;
    start) start_service ;;
    stop) stop_service ;;
    restart) restart_service ;;
    status) status_service ;;
    logs) logs_service ;;
    uninstall) uninstall_service ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"

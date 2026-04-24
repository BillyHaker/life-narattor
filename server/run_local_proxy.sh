#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f ".env" ]; then
  echo "Missing .env in $SCRIPT_DIR. Copy .env.example to .env first."
  exit 1
fi

set -a
source .env
set +a

NODE_BIN="${NODE_BIN:-$(command -v node || true)}"
if [ -z "$NODE_BIN" ]; then
  echo "Node.js not found in PATH. Install Node.js 18+ and retry."
  exit 1
fi

exec "$NODE_BIN" server.js

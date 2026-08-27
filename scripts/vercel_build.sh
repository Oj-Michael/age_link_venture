#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT_DIR/.flutter/flutter/bin:$PATH"
export CI=true

flutter build web --release --no-wasm-dry-run

if [ ! -f "$ROOT_DIR/build/web/index.html" ]; then
  echo "ERROR: build/web/index.html was not created."
  exit 1
fi

echo "Flutter web build succeeded."

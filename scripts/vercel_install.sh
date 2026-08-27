#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_DIR="$ROOT_DIR/.flutter"

if [ ! -d "$FLUTTER_DIR/flutter" ]; then
  echo "Cloning Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR/flutter"
fi

export PATH="$FLUTTER_DIR/flutter/bin:$PATH"
export CI=true

flutter --version
flutter config --enable-web --no-analytics
flutter pub get

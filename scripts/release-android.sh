#!/usr/bin/env bash
# Build Android App Bundle (AAB) for Play Store upload.
# Prefer: kasy android release (configure signing first with kasy android configure)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f pubspec.yaml ]]; then
  echo "pubspec.yaml not found. Run from the Flutter project root." >&2
  exit 1
fi

KEY_PROPS="${ROOT}/android/key.properties"
if [[ ! -f "$KEY_PROPS" ]]; then
  echo "android/key.properties not found. Run: kasy android configure" >&2
  exit 1
fi

load_dart_defines() {
  DEFINES_ARGS=()
  if [[ -f .dart_defines ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ -z "$line" || "$line" =~ ^# ]] && continue
      DEFINES_ARGS+=("$line")
    done < .dart_defines
  elif [[ -f .vscode/launch.json ]]; then
    :
  fi
  if [[ ${#DEFINES_ARGS[@]} -eq 0 ]]; then
    DEFINES_ARGS+=(--dart-define=ENV=prod)
  fi
}

load_dart_defines

echo "Building Android App Bundle (release)..."
flutter build appbundle --release "${DEFINES_ARGS[@]}"

OUT="${ROOT}/build/app/outputs/bundle/release/app-release.aab"
if [[ -f "$OUT" ]]; then
  echo ""
  echo "AAB ready: $OUT"
  echo "Upload this file in Google Play Console."
fi

#!/usr/bin/env bash
# take_screenshots.sh — Run Flutter screenshot integration tests
#
# Usage:
#   ./take_screenshots.sh --app FastTrack
#   ./take_screenshots.sh --app MoodTrack
#   ./take_screenshots.sh --app SubTrack
#
# Prerequisites:
#   - macOS with Xcode installed
#   - Flutter installed
#   - Run from the PorchLightSoftwareCommon/scripts/ directory
#     OR provide full path to app with --path

set -euo pipefail

APP=""
APP_PATH=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Simulators to capture (name must match `xcrun simctl list`)
SIMULATORS=(
  "iPhone 16 Pro Max"   # 6.7"
  "iPhone 14 Plus"      # 6.5"
  "iPhone 8 Plus"       # 5.5"
)

usage() {
  echo "Usage: $0 --app <AppName> [--path <path_to_app>]"
  echo "  --app   App name: FastTrack, MoodTrack, or SubTrack"
  echo "  --path  Absolute path to app folder (optional, defaults to sibling of this repo)"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --app)  APP="$2"; shift 2 ;;
    --path) APP_PATH="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "$APP" ]] && usage

if [[ -z "$APP_PATH" ]]; then
  APP_PATH="$PARENT_DIR/../$APP"
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: App folder not found at $APP_PATH"
  exit 1
fi

SCREENSHOTS_DIR="$APP_PATH/screenshots"
mkdir -p "$SCREENSHOTS_DIR"

echo "Taking screenshots for $APP..."

for SIM in "${SIMULATORS[@]}"; do
  echo ""
  echo "--- Simulator: $SIM ---"

  # Boot simulator
  SIM_ID=$(xcrun simctl list devices available | grep "$SIM" | head -1 | grep -oE '[A-F0-9-]{36}')
  if [[ -z "$SIM_ID" ]]; then
    echo "Warning: Simulator '$SIM' not found, skipping."
    continue
  fi

  xcrun simctl boot "$SIM_ID" 2>/dev/null || true

  SAFE_SIM="${SIM// /_}"
  OUTPUT_DIR="$SCREENSHOTS_DIR/$SAFE_SIM"
  mkdir -p "$OUTPUT_DIR"

  cd "$APP_PATH"

  # Run screenshot integration test
  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/screenshot_test.dart \
    --device-id="$SIM_ID" \
    --dart-define=SCREENSHOTS_DIR="$OUTPUT_DIR" \
    || echo "Warning: Screenshot test failed for $SIM"

  echo "Screenshots saved to $OUTPUT_DIR"
done

echo ""
echo "Done! Screenshots saved to $SCREENSHOTS_DIR"

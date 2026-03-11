#!/usr/bin/env bash
# deploy_all.sh — Deploy all Porch Light Software apps to TestFlight
#
# Usage:
#   ./deploy_all.sh           # Deploy all apps
#   ./deploy_all.sh fasttrack # Deploy only FastTrack
#
# Run from any directory. Requires Fastlane installed and env vars set.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
APPS_DIR="$(dirname "$PARENT_DIR")"

APPS=("FastTrack" "MoodTrack" "SubTrack")

# Filter to specific app if argument provided
if [[ $# -gt 0 ]]; then
  REQUESTED="${1,,}"  # lowercase
  APPS=()
  for APP in "FastTrack" "MoodTrack" "SubTrack"; do
    if [[ "${APP,,}" == *"$REQUESTED"* ]]; then
      APPS+=("$APP")
    fi
  done
  if [[ ${#APPS[@]} -eq 0 ]]; then
    echo "Error: No app matching '$1'. Valid: FastTrack, MoodTrack, SubTrack"
    exit 1
  fi
fi

FAILED=()

for APP in "${APPS[@]}"; do
  APP_PATH="$APPS_DIR/$APP"
  echo ""
  echo "=========================================="
  echo "Deploying $APP..."
  echo "=========================================="

  if [[ ! -d "$APP_PATH/ios/fastlane" ]]; then
    echo "Error: No fastlane folder found at $APP_PATH/ios/fastlane"
    FAILED+=("$APP")
    continue
  fi

  cd "$APP_PATH"

  if bundle exec fastlane beta; then
    echo "$APP deployed successfully!"
  else
    echo "Error: $APP deployment failed!"
    FAILED+=("$APP")
  fi
done

echo ""
if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo "All apps deployed successfully!"
else
  echo "Failed apps: ${FAILED[*]}"
  exit 1
fi

#!/bin/bash

set -e

# Default values
INCREMENT=false
BUMP_TYPE=patch

# Parse parameters
for arg in "$@"; do
  case $arg in
    increment=*)
      INCREMENT="${arg#*=}"
      shift
      ;;
    type=*)
      BUMP_TYPE="${arg#*=}"
      shift
      ;;
  esac
done

# If increment=true, bump the version
if [ "$INCREMENT" = true ]; then
  echo "🔄 Bumping version ($BUMP_TYPE)..."
  chmod +x ./bump_version.sh
  ./bump_version.sh "$BUMP_TYPE"
fi

# Clean and Build
flutter clean
echo "✅ Clean completed!"

flutter pub get
echo "✅ Dependencies updated, fetched!"

# Build AAB
flutter build appbundle --release
echo "✅ Release AAB ready!"

# Prepare paths
VERSION_LINE=$(grep '^version:' pubspec.yaml | head -n 1)
VERSION_CODE=$(echo "$VERSION_LINE" | sed 's/.*+//')
AAB_OUTPUT_DIR="build/app/outputs/bundle/release"
TARGET_DIR="build/releases"
NEW_AAB_FILENAME="tile-titans-release-${VERSION_CODE}.aab"

# Create target dir
mkdir -p "${TARGET_DIR}"

# Move built AAB
if [ -f "${AAB_OUTPUT_DIR}/app-release.aab" ]; then
    AAB_PATH="${AAB_OUTPUT_DIR}/app-release.aab"
    cp "$AAB_PATH" "${TARGET_DIR}/${NEW_AAB_FILENAME}"
    echo "✅ AAB exported successfully to ${TARGET_DIR}/${NEW_AAB_FILENAME}"
else
    echo "❌ AAB not found!"
    exit 1
fi

# Output path
echo "${TARGET_DIR}/${NEW_AAB_FILENAME}"

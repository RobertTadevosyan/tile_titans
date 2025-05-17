#!/bin/bash

set -e

# If no argument is passed, default to "minor"
BUMP_TYPE=${1:-minor}

# Read current version from pubspec.yaml
VERSION_LINE=$(grep "^version:" pubspec.yaml)
CURRENT_VERSION=$(echo "$VERSION_LINE" | awk '{print $2}')
VERSION_NAME=${CURRENT_VERSION%%+*}
VERSION_CODE=${CURRENT_VERSION##*+}

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"

case "$BUMP_TYPE" in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  *)
    echo "❌ Invalid parameter. Use: minor, medium, or major"
    exit 1
    ;;
esac

NEW_VERSION_NAME="$MAJOR.$MINOR.$PATCH"
NEW_VERSION_CODE=$((VERSION_CODE + 1))

# Update pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION_NAME+$NEW_VERSION_CODE/" pubspec.yaml
rm pubspec.yaml.bak

echo "✅ Version bumped to: $NEW_VERSION_NAME+$NEW_VERSION_CODE"

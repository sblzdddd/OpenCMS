#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

DIST_DIR="build/dist"
SYMBOLS_DIR="build/app/outputs/symbols"
APK_OUTPUT_DIR="build/app/outputs/flutter-apk"
LINUX_BUNDLE_DIR="build/linux/x64/release/bundle"
PUBSPEC_FILE="pubspec.yaml"
APP_VERSION="$(grep -E '^version:' "$PUBSPEC_FILE" | head -n1 | sed -E 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)(\+[0-9]+)?[[:space:]]*$/\1/')"
if [[ -z "$APP_VERSION" || "$APP_VERSION" == "version:"* ]]; then
	APP_VERSION="0.0.0"
fi
LINUX_ZIP_NAME="OpenCMS_${APP_VERSION}.linux64.zip"
LINUX_ZIP_PATH="$DIST_DIR/$LINUX_ZIP_NAME"

mkdir -p "$DIST_DIR" "$SYMBOLS_DIR"

echo "==> Building APKs (release, obfuscate, split per ABI)..."
flutter build apk \
	--release \
	--obfuscate \
	--split-debug-info="$SYMBOLS_DIR" \
	--split-per-abi \
	--tree-shake-icons

echo "==> Collecting APK artifacts into $DIST_DIR ..."
find "$APK_OUTPUT_DIR" -maxdepth 1 -type f -name "app-*-release.apk" -exec cp -f {} "$DIST_DIR" \;

echo "==> Building Linux (release, obfuscate, strip debug info)..."
flutter build linux \
	--release \
	--obfuscate \
	--split-debug-info="$SYMBOLS_DIR" \
	--tree-shake-icons

if command -v strip >/dev/null 2>&1; then
	echo "==> Stripping Linux binaries/symbols for smaller size..."
	find "$LINUX_BUNDLE_DIR" -type f \( -name "*.so" -o -name "OpenCMS" -o -name "opencms" \) -exec strip --strip-unneeded {} + || true
fi

echo "==> Creating max-compressed Linux zip: $LINUX_ZIP_NAME"
rm -f "$LINUX_ZIP_PATH"
(
	cd "$(dirname "$LINUX_BUNDLE_DIR")"
	zip -r -9 "${ROOT_DIR}/${LINUX_ZIP_PATH}" "$(basename "$LINUX_BUNDLE_DIR")"
)

echo "==> Build artifacts available in $DIST_DIR"
ls -lh "$DIST_DIR"

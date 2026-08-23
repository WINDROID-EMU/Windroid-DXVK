#!/usr/bin/env bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <version> <output_dir>"
  echo "Example: $0 3.0.2-TurnipFix build"
  exit 1
fi

VERSION="$1"
OUT_DIR=$(realpath "$2")
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
RAT_DIR="$OUT_DIR/rat-pkg-$VERSION"
RAT_FILE="$OUT_DIR/DXVK-$VERSION-any.rat"

mkdir -p "$OUT_DIR"
rm -rf "$RAT_DIR" "$RAT_FILE"

# Build DXVK binaries if not already built in $OUT_DIR/dxvk-$VERSION
if [ ! -d "$OUT_DIR/dxvk-$VERSION/x64" ] || [ ! -d "$OUT_DIR/dxvk-$VERSION/x32" ]; then
  "$SCRIPT_DIR/package-release.sh" "$VERSION" "$OUT_DIR" --no-package
fi

# Prepare RAT structure
mkdir -p "$RAT_DIR/files/x64" "$RAT_DIR/files/x32"

cp -r "$OUT_DIR/dxvk-$VERSION/x64/"*.dll "$RAT_DIR/files/x64/"
cp -r "$OUT_DIR/dxvk-$VERSION/x32/"*.dll "$RAT_DIR/files/x32/"

# Create pkg-header for Windroid package manager
cat <<EOF > "$RAT_DIR/pkg-header"
name=DXVK
category=DXVK
version=$VERSION
architecture=any
vkDriverLib=
EOF

# Package with tar.xz (matches create-rat-pkg.sh standard)
tar -cJf "$RAT_FILE" -C "$RAT_DIR" pkg-header files

echo "Successfully created RAT package: $RAT_FILE"

# Clean temporary RAT staging dir
rm -rf "$RAT_DIR"

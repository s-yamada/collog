#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARE_DIR="$HOME/.local/share/collog"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$SHARE_DIR" "$BIN_DIR"
cp "$SRC_DIR/collog" "$SHARE_DIR/collog"
chmod 755 "$SHARE_DIR/collog"
ln -sf "$SHARE_DIR/collog" "$BIN_DIR/collog"

echo "installed: $SHARE_DIR/collog"
echo "launcher : $BIN_DIR/collog -> $SHARE_DIR/collog"

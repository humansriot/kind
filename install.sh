#!/usr/bin/env bash
set -euo pipefail

HELPER=kind
INSTALL_PATH="$HOME"/.humansriot/$HELPER

# Clone repository
rm -rf "$INSTALL_PATH"
mkdir -p "$INSTALL_PATH"
cd "$(dirname "$INSTALL_PATH")"
git clone git@github.com:humansriot/$HELPER.git

# Link tools
ln -sf "$INSTALL_PATH"/kind_helper.sh /usr/local/bin/kind_helper

#!/usr/bin/env bash
set -euo pipefail

ORG=humansriot
HELPER=kind
INSTALL_PATH="$HOME"/.$ORG/$HELPER

# Clone repository
rm -rf "$INSTALL_PATH"
mkdir -p "$INSTALL_PATH"
cd "$(dirname "$INSTALL_PATH")"
git clone git@github.com:$ORG/$HELPER.git || git clone https://github.com/$ORG/$HELPER.git > /dev/null

# Link tools
sudo ln -sf "$INSTALL_PATH"/kind_helper.sh /usr/local/bin/kind_helper

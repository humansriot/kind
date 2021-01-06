#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME"/.humansriot
cd "$HOME"/.humansriot
git clone git@github.com:humansriot/kind.git
ln -sf "$PWD"/kind/kind_helper.sh /usr/local/bin/kind_helper

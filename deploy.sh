#!/usr/bin/env bash

set -euo pipefail

./copy-to-local.sh

# Use HEAD commit title in the bootloader entry label
# FIXME this breaks if there is whitespace in the commit message?!?
export NIXOS_LABEL=$(git show -s --format=%s)
sudo --preserve-env=NIXOS_LABEL nixos-rebuild switch --show-trace

#!/usr/bin/env bash

set -euo pipefail

./copy-to-local.sh

# this is supposed to make nixos-rebuild switch use this in the bootloader entry, but for some reason it doesn't work
# adding --impure to the switch command doesn't help either.
export NIXOS_LABEL=$(git show -s --format=%s)

sudo nixos-rebuild switch

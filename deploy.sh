#!/usr/bin/env bash

set -euo pipefail

./copy-to-local.sh

export NIXOS_LABEL=$(git show -s --format=%s)
sudo nixos-rebuild switch

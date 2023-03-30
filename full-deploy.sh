#!/usr/bin/env bash

set -euo pipefail

./copy-to-local.sh

sudo nixos-rebuild switch --show-trace
home-manager build switch --show-trace

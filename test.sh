#!/usr/bin/env bash

set -euo pipefail
# when allow-dirty is not set to false, the CLI raises a warning but IGNORES the dirty part of the working tree,
# which leads to very surprising behaviour and hard to work out errors. Because of this, we opt for the alternative
# which is a faff during local dev, but prevents such problems.
sudo nixos-rebuild test  --option allow-dirty false --flake . 

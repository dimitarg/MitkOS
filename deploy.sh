#!/usr/bin/env bash

set -euo pipefail
# when allow-dirty is not set to false, the CLI raises a warning but IGNORES the dirty part of the working tree,
# which leads to very surprising behaviour and hard to work out errors. Because of this, we opt for the alternative
# which is a faff during local dev, but prevents such problems.
# Set through NIX_CONFIG rather than nh's extra args, since those only reach `nix build` and not nh's evaluation steps.
# nh elevates privileges itself for activation, so it must not be run under sudo.
# --ask shows the package diff and asks for confirmation before activating.
NIX_CONFIG="allow-dirty = false" nh os switch --ask .

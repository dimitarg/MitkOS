#!/usr/bin/env bash

set -euo pipefail

nix flake update
git add .
git commit -m "Updates"

# Build the updated system (without activating it) to show what the update brings in.
# Runs after the commit, as the uncommitted flake.lock would otherwise trip allow-dirty = false.
NIX_CONFIG="allow-dirty = false" nh os build .

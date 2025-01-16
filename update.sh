#!/usr/bin/env bash

set -euo pipefail

nix flake update
git add .
git commit -m "Updates"

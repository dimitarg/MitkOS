#!/usr/bin/env bash

set -euo pipefail

nix flake update

# this does not affect the system derivation / build
# nix channels are only used in non-flakified CLIs such as nix-shell , etc
# this update is only done in order to keep flake.lock and channels somewhat consistent, until we figure out a better solution
nix-channel --update
sudo nix-channel --update

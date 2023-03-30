#!/usr/bin/env bash

set -euo pipefail

sudo nix-channel --update # system
nix-channel --update # home manager
./full-deploy.sh

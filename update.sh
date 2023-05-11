#!/usr/bin/env bash

set -euo pipefail

sudo nix-channel --update # system
./deploy.sh

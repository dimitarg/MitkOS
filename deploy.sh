#!/usr/bin/env bash

set -euo pipefail

sudo nixos-rebuild switch --option allow-dirty false --flake .


#!/usr/bin/env bash

set -euo pipefail

set -euo pipefail
echo "Copying nixos system configuration from local host to git repository, under ./hosts/$(hostname)"
cp -a --verbose /etc/nixos/. "hosts/$(hostname)/"
echo "Copying home manager configuration from local host to git repository"
cp -a --verbose ~/.config/home-manager/. home-manager/

git status

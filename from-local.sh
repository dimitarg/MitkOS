#!/usr/bin/env bash

set -euo pipefail
echo "Copying nixos system configuration from local host to git repository, under ./hosts/$(hostname)"
cp -a /etc/nixos/. "hosts/$(hostname)/"
echo "Copying home manager configuration from local host to git repository"
cp -a ~/.config/nixpkgs/. home-manager/

git status

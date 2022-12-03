#!/usr/bin/env bash

set -euo pipefail
echo "Copying nixos system configuration from ./hosts/$(hostname) to local host (this needs sudo)"
sudo cp -a --verbose "hosts/$(hostname)/." /etc/nixos/
echo "Copying home manager configuration from git repository to local host"
cp -a --verbose home-manager/. ~/.config/nixpkg

echo "Dry build of system (nixos-rebuild) configuration:"
nixos-rebuild dry-build

echo ""
echo "Dry build of the home manager configuration:"
echo "Sorry, I don't know how to do that yet."

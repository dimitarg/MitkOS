#!/usr/bin/env bash

set -euo pipefail
echo "Copying flake.nix to local host (this needs sudo)"
sudo cp -a --verbose flake.nix /etc/nixos/
sudo cp -a --verbose flake.lock /etc/nixos/
echo "Copying nixos system configuration from ./hosts/$(hostname) to local host (this needs sudo)"
sudo cp -a --verbose "hosts/$(hostname)/." /etc/nixos/
echo "Copying home manager configuration from git repository to local host (this needs sudo)"
cp -a --verbose home-manager/. /etc/nixos/home-manager

#!/usr/bin/env bash

set -euo pipefail
echo "Copying nixos system configuration from ./hosts/$(hostname) to local host (this needs sudo)"
sudo cp -a "hosts/$(hostname)/." /etc/nixos/
echo "Copying home manager configuration from git repository to local host"
cp -a home-manager/. ~/.config/nixpkgs/ 

#!/usr/bin/env bash

set -euo pipefail
echo "Copying nixos system configuration from ./hosts/$(hostname) to local host (this needs sudo)"
sudo cp -a --verbose "hosts/$(hostname)/." /etc/nixos/
echo "Copying home manager configuration from git repository to local host (this needs sudo)"
cp -a --verbose home-manager/. /etc/nixos/home-manager

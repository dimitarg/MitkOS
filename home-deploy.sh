#!/usr/bin/env bash

set -euo pipefail

./copy-to-local.sh

home-manager build switch

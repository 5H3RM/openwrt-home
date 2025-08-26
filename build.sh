#!/usr/bin/env bash
set -euo pipefail
PROFILE=linksys_mx4200
PKGS="$(tr '\n' ' ' < packages/core.txt) $(tr '\n' ' ' < packages/stats.txt)"
make image PROFILE="$PROFILE" PACKAGES="$PKGS" FILES=files/

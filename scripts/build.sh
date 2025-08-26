#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   1) Download the matching OpenWrt ImageBuilder for your device/release.
#      Example (adjust release/target as needed):
#      - Go to https://downloads.openwrt.org/releases/<VERSION>/targets/qualcommax/ipq807x/
#      - Download & extract: openwrt-imagebuilder-<VERSION>-qualcommax-ipq807x.Linux-x86_64.tar.xz
#   2) Copy this repo into the ImageBuilder dir (or vice versa).
#   3) Run: ./scripts/build.sh
#
# Tips:
#   - Verify profile name with: make info | grep -A3 linksys
#   - Don't list base OS packages; IB provides them.
#   - Edit files/etc/uci-defaults/99-home-mesh before building.

PROFILE="linksys_mx4200"

CORE_PKGS=$(tr '\n' ' ' < packages/core.txt)
STATS_PKGS=$(tr '\n' ' ' < packages/stats.txt)
PKGS="${CORE_PKGS} ${STATS_PKGS}"

echo "==> Building for PROFILE=${PROFILE}"
echo "==> PACKAGES=${PKGS}"
make image PROFILE="${PROFILE}" PACKAGES="${PKGS}" FILES=files/

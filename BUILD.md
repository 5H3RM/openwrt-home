# OpenWrt Firmware Build (MX4200)

This document describes how custom OpenWrt firmware images for my home network are built.

Target hardware:
- Linksys MX4200 (all APs)
- Platform: ipq807x / qualcommax

Build tooling:
- owut (OpenWrt image builder wrapper)

---

## Build Host

Firmware builds are performed on:

- OS: ____________________
- Docker / Native: ____________________
- owut version: ____________________

---

## Target Profile

OpenWrt Target:
- qualcommax/ipq807x
- Device: linksys_mx4200v1

---

## Package Selection

Core packages included in the custom image:

- batman-adv
- kmod-batman-adv
- batctl
- vlan / bridge related utilities
- luci
- luci-ssl
- iw
- tcpdump
- ethtool

(Full package list should match owut build config.)

Optional / future packages:
- mesh diagnostics
- monitoring tools
- VPN (if added later)

---

## Build Command

Baseline owut command used to generate images:

```bash
owut build \
  --target qualcommax/ipq807x \
  --profile linksys_mx4200v1 \
  --packages "<PACKAGE LIST HERE>" \
  --output images/

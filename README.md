# OpenWrt Home Network – Infrastructure as Code

This repository contains:
- Custom OpenWrt firmware builds
- Per-AP configuration backups
- Network topology documentation
- Mesh and VLAN design for my home network

All access points are based on Linksys MX4200 hardware and run OpenWrt.

---

## Hardware
- Linksys MX4200 (AP-1)
- Linksys MX4200 (AP-2)
- Linksys MX4200 – Garage (AP-3)

---

## Network Overview
Core routing and DHCP are handled upstream. All APs operate as bridged access points with VLAN trunking.

Primary VLANs:
- Home
- Guest
- IoT
- Management

Backhaul:
- House APs: wired + mesh
- Garage AP: currently migrating to wired (previously mesh)

Mesh is implemented using batman-adv.

---

## Repository Structure

openwrt-home/
├── images/ # Custom firmware binaries + build config
├── ap1/ # AP-1 configs
├── ap2/ # AP-2 configs
├── ap3/ # Garage AP configs
├── diagrams/ # Network topology diagrams
├── BUILD.md # Firmware build instructions
├── RESTORE.md # Full AP recovery process
└── README.md

---

## Firmware Builds

Custom firmware images are built using owut and stored in `/images`.

The build configuration and package list are documented in `BUILD.md`.

Only known-good images should be committed.

---

## Configuration Backups

Each AP folder contains:
- `network`
- `wireless`
- `system`
- `firewall` (if modified)

These files are direct copies from `/etc/config` on the router.

Sensitive values (PSKs, secrets, keys) are redacted before commit.

---

## Disaster Recovery

Full rebuild steps are documented in `RESTORE.md`.

At a high level:
1. Flash custom sysupgrade firmware
2. Copy configuration files from this repo
3. Reboot and verify mesh + VLAN operation

---

## Security

This repository is public.
Do NOT commit:
- WPA keys
- VPN private keys
- Admin passwords
- API tokens

Use placeholders where required.

---

## Goals

- Reproducible firmware
- Versioned AP configuration
- Documented VLAN + mesh design
- Fast disaster recovery
- Minimal manual rebuild effort

---

## Status

Actively maintained.
Last major work:
- Mesh backhaul tuning
- Garage AP recovery
- VLAN propagation across mesh

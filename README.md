# OpenWrt Home – Automated Builds + AP Backups ✨

Custom OpenWrt build configuration for my Linksys MX4200 v1 access points. GitHub Actions builds reproducible sysupgrade images with my package sets, custom feeds, and overlay files. Per-AP configs, diagrams, and recovery docs keep rebuilds quick and repeatable.

---

## 🛠️ Build pipeline (GitHub Actions)
- ImageBuilder inside Actions; resolves the latest patch in the selected series (e.g., 24.10.x).
- Pulls ImageBuilder tarball, injects feeds from `custom-feeds/`, and keys from `keys/`.
- Reads every list in `packages/`, strips base OS packages, and feeds the cleaned set to ImageBuilder.
- Embeds everything under `/files` as the overlay (create this directory locally as needed).
- Outputs `*sysupgrade.bin`, uploads as an artifact, and publishes a GitHub Release.
- Outcome: no manual package reinstalls and fully reproducible firmware.

---

## 🗂️ Repo at a glance

```
openwrt-home/
├── packages/           # Modular package lists (auto-loaded)
├── custom-feeds/       # Additional feed definitions (workflow expects this name)
├── keys/               # Feed signing keys copied into ImageBuilder
├── files/              # Overlay injected into the firmware rootfs (create as needed)
├── ap1/                # AP-1 config backups
├── ap2/                # AP-2 config backups
├── diagrams/           # Network topology diagrams
├── .github/workflows/  # build.yml (automated ImageBuilder workflow)
├── BUILD.md            # Firmware build notes
├── RESTORE.md          # Full AP recovery process
└── README.md
```

Notes:
- The repo currently contains `custom feeds/` with a space; the workflow looks for `custom-feeds/`. Rename or symlink to match the workflow before building.
- Add more AP folders (e.g., `ap3/`) as devices come online.

---

## 📦 Adding or updating packages
- Every file in `packages/` is read automatically.
- Edit an existing list or add a new one (e.g., `mesh.txt`, `vpn.txt`); one package per line.
- `#` comments are allowed; no workflow edits needed.

Example:
```
# networking tools
ethtool
bind-dig
tcpdump
luci-app-opkg
```

---

## 🛰 Custom feeds (e.g., fantastic-packages)
- Drop feed definitions into `custom-feeds/`.
- Example (`custom-feeds/fantastic.conf`):
  ```
  src/gz fantastic_packages https://fantastic-packages.github.io/releases/aarch64_cortex-a53
  ```
- Versionless URLs track new OpenWrt releases automatically; any `.conf` in this folder is injected.

---

## 🔑 Custom signing keys
- Place feed keys in `keys/`; they are copied into ImageBuilder’s `keys/` directory.

---

## 🗳️ Overlay files (/files)
- Everything inside `/files` copies into the final firmware filesystem and overwrites defaults.
- Use this for VLAN/mesh configs, wireless radios, hotplug scripts, custom banners, and other defaults.
- Examples:
  - `files/etc/config/network`
  - `files/etc/config/wireless`
  - `files/etc/banner`

---

## 📤 Firmware output
- Artifact name: `openwrt-<version>-linksys_mx4200v1-squashfs-sysupgrade.bin`.
- Available via GitHub Actions artifacts and GitHub Releases (tagged per OpenWrt version).
- Flash with `sysupgrade -n /tmp/firmware.bin` or via LuCI.

---

## 🔄 Upgrading OpenWrt release versions
- Change `OPENWRT_SERIES` in `.github/workflows/build.yml` (e.g., to `"24.11"`).
- Push the change; the workflow resolves the latest patch, pulls ImageBuilder, injects feeds/keys/packages, and builds a matching image.

---

## 📚 Backups and AP configs
- Each AP folder contains redacted `/etc/config` backups (`network`, `wireless`, `system`, `firewall` when applicable).
- Core routing and DHCP are handled upstream; APs run as bridged devices with VLAN trunking.
- VLANs: Home, Guest, IoT, Management.
- Backhaul: wired + mesh for house APs; garage AP migrating to wired. Mesh uses batman-adv.

---

## 🧯 Disaster recovery
- See `RESTORE.md` for the full rebuild flow.
- High level:
  1) Flash the custom sysupgrade image.
  2) Copy configuration files from this repo.
  3) Reboot and verify mesh + VLAN operation.

---

## 🔒 Security
- Public repo; do **not** commit WPA keys, VPN private keys, admin passwords, or API tokens.
- Use placeholders for any sensitive values.

---

## 🎯 Goals
- Reproducible firmware images
- Versioned AP configurations
- Documented VLAN + mesh design
- Fast disaster recovery with minimal manual steps

# OpenWrt Home AP Build (MX4200v1)

Reproducible images for Aaron's three Linksys MX4200v1 APs with:
- 802.11s + BATMAN-adv mesh (radio0, 5 GHz ch36 HE80)
- Per‑VLAN overlay bridges (bat0.<VID> ↔ bridge.<VID>) so DSA + mesh play nice
- WAN & LAN3 = untagged MGMT (VLAN 99), LAN1/2 = untagged IoT (VLAN 10)
- SSIDs (Home/Guest/IoT) on all radios, no client isolation
- LuCI TLS, NTP set, firewall disabled (pfSense in front), watchcat disabled
- Collectd + vnstat graphs enabled

## Layout

```
openwrt-home/
├─ files/
│  └─ etc/uci-defaults/99-home-mesh     # first‑boot config script
├─ packages/
│  ├─ core.txt                          # mesh/admin baseline
│  └─ stats.txt                         # collectd/vnstat bundle
└─ scripts/
   └─ build.sh                          # ImageBuilder wrapper
```

## Build

1. Download/extract the **ImageBuilder** for your release/target (MX4200v1 = `qualcommax/ipq807x`).  
2. Put this repo next to (or inside) the ImageBuilder directory.
3. Edit `files/etc/uci-defaults/99-home-mesh` to set SSIDs/keys/mesh pass.
4. Run:
   ```bash
   ./scripts/build.sh
   ```
5. Flash the resulting `*sysupgrade.bin` with **don't keep settings**.

## Notes
- Keep package lists minimal; base OS packages are provided by ImageBuilder.
- If you later want third‑party feeds (e.g., “Fantastic”), add their feed URL/key
  to `repositories.conf` and build with `REPOSITORIES_CONF=./repositories.conf`.
- Verify profile names with `make info` inside ImageBuilder.

# OpenWrt AP Restore & Disaster Recovery Guide

**Target Platform:** Linksys MX4200  
**Firmware:** OpenWrt (custom owut builds)  
**Applies To:** AP-1, AP-2, AP-3 (Garage)

This document describes the **complete recovery process** for rebuilding any access point in this repository from scratch.

Use this guide for:

* Firmware corruption
* Failed upgrades
* Hardware replacement
* Clean rebuilds
* Misconfiguration recovery

---

## What You Need

* A known-good **sysupgrade image** from the `/images` folder
* A PC with Ethernet
* SCP / SSH access
* (Optional for hard bricks) Serial + TFTP setup

---

## Recovery Types

### Soft Recovery

Use when:

* The device still boots into OpenWrt
* You still have SSH or LuCI access

### Hard Recovery

Use when:

* The device does not boot OpenWrt
* Firmware partitions are corrupted
* Only U-Boot is accessible

---

## SOFT RECOVERY (Most Common)

### Step 1 – Flash the Firmware

Copy the known-good firmware to the AP:

```bash
scp images/mx4200-owut-<version>.bin root@192.168.1.1:/tmp/
```

Flash it:

```bash
sysupgrade -n /tmp/mx4200-owut-<version>.bin
```

Wait for reboot (2–3 minutes).

---

### Step 2 – Verify Base System

Reconnect after reboot:

```bash
ssh root@192.168.1.1
```

Verify firmware:

```bash
ubus call system board
```

Verify interfaces:

```bash
ip addr
iw dev
```

---

### Step 3 – Restore Configuration Files

From your workstation, restore configs for the correct AP:

```bash
scp apX/network  root@192.168.1.1:/etc/config/network
scp apX/wireless root@192.168.1.1:/etc/config/wireless
scp apX/system   root@192.168.1.1:/etc/config/system
scp apX/firewall root@192.168.1.1:/etc/config/firewall
```

(Replace `apX` with `ap1`, `ap2`, or `ap3`.)

After copying configs, always verify:
/etc/config/network
/etc/config/wireless
/etc/config/system
/etc/config/firewall

Match these against the GitHub repo before rebooting.

Reboot the AP:

```bash
reboot
```

---

### Step 4 – Post-Restore Verification

After reboot, verify:

```bash
ip addr
brctl show
batctl o
iw dev
```

Confirm:

* Radios are up
* VLAN bridges exist
* Mesh links form correctly
* Upstream connectivity works

---

### Step 5 – Re-Enter Secrets (Manual)

The following values are **never stored in Git** and must be restored manually:

* SSID passphrases
* Mesh encryption key
* Admin/root passwords
* VPN private keys (if used)

Restore secrets via:

* LuCI
* or `uci` CLI commands

---

### Step 6 – Functional Testing

* Connect a client to Home SSID
* Verify DHCP and internet access
* Test Guest isolation
* Verify IoT access rules
* Walk-test roaming between APs
* If mesh is used, confirm:

```bash
batctl o
```

---

## HARD RECOVERY (U-Boot / Serial / TFTP)

Use this only if the AP will not boot OpenWrt.

### Step 1 – Connect Serial

* Baud: **115200**
* 8N1
* Interrupt boot to reach U-Boot prompt

---

### Step 2 – Set Network Parameters

```bash
setenv ipaddr 192.168.1.1
setenv serverip 192.168.1.12
saveenv
```

---

### Step 3 – Boot OpenWrt Initramfs via TFTP

From U-Boot:

```bash
tftpboot $loadaddr initramfs.itb
bootm $loadaddr
```

Wait for OpenWrt to boot into RAM.

---

### Step 4 – Flash Sysupgrade Normally

From the RAM-booted OpenWrt shell:

```bash
scp mx4200-owut-<version>.bin root@192.168.1.1:/tmp/
sysupgrade -n /tmp/mx4200-owut-<version>.bin
```

Wait for reboot.

Then continue at **SOFT RECOVERY – Step 2**.

---

## Post-Recovery Validation Checklist

* [ ] Correct firmware version installed
* [ ] VLAN bridges active
* [ ] Mesh operational (if applicable)
* [ ] Upstream connectivity verified
* [ ] SSIDs broadcasting correctly
* [ ] Security rules enforced properly

---

## Important Notes

* APs act as **bridged devices only**
* No DHCP or NAT is performed on APs
* Routing is handled upstream
* This repo is the **source of truth** for all AP configurations
* Do **not** store secrets in Git

---

## Emergency Rollback

If a new firmware or config breaks the network:

1. Re-flash last known-good firmware from `/images`
2. Re-apply previous configs from Git history
3. Reboot and validate



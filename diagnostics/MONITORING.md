# AP reboot monitoring

Run the two collectors below for the next two days. Keep the collecting PC awake and connected, preferably by Ethernet. They change no AP configuration and install nothing. Stop with Ctrl+C. Logs can contain client addresses; keep them private.

## 1. Fleet reachability (no passwords needed)

Open PowerShell in the folder containing these files and run:

```powershell
.\Watch-APFleet.ps1
```

This probes the gateway and all six APs about every ten seconds for 48 hours, writes timestamped CSV, and prints state changes. The default addresses follow the fleet's existing management subnet. Override them with `-Addresses @('address1','address2')` if needed. Failed probes are outages from this PC's perspective, not proof of a reboot. If every target fails together, inspect the collector's connection and upstream infrastructure too. CSV timestamps include the time-zone offset. Closing the window or sleeping the PC interrupts collection.

## 2. AP2 logs and resource trend (existing SSH access required)

First verify SSH login using your existing credentials. Check a first-use host fingerprint against a trusted record before accepting it. Enter passwords only at SSH's password prompt; do not put them in commands or files.

Then run this in a separate PowerShell window from this folder:

```powershell
$capture = 'AP2-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log'
Get-Content -Raw .\ap-telemetry.sh | ssh -T -o ServerAliveInterval=15 -o ServerAliveCountMax=3 root@10.99.99.252 sh -s | Tee-Object -FilePath $capture
```

The shell script sends the initial kernel log, follows the system log, and samples boot ID, uptime, memory, swap, disk usage, temperatures where available, and gateway reachability roughly once a minute. It runs at most 2,880 samples (approximately 48 hours plus probe overhead). Output is written on the PC, not the AP's flash. No passwords or wireless configuration are read. The SSH session ends on a reboot or connection loss; reconnect and rerun with a new filename when the AP returns. Password-based reconnects need a person. For unattended capture across reboots, use an existing SSH agent/key with a reconnecting collector or a trusted remote syslog receiver.

Repeat for AP1 and AP5 in separate windows by changing both the filename prefix and target address when they are reachable.

## Interpreting evidence

- A changed boot ID or reset uptime confirms a reboot; ping loss alone does not.
- Watchcat messages just before loss can establish a connectivity-triggered reboot. Confirm its live target is an external reachable management host, not the AP's own address. Do not change its action or target during baseline collection without considering reboot loops during upstream outages.
- Kernel panic, ath10k/ath11k firmware crash, watchdog, or out-of-memory messages narrow the cause. Falling MemAvailable with growing SUnreclaim suggests kernel memory pressure to investigate; one high memory reading does not prove a leak.
- A sudden silent end can also mean power loss, network loss, or a hard lockup. Compare switch port/PoE/UPS logs and the fleet CSV.
- UBIFS recovery after boot is compatible with an unclean shutdown; it is not a unique power-loss diagnosis.
- LuCI's Storage bar reports USED bytes. A small percentage does not mean the disk is full.

## Additional read-only checks after a reboot

Use an interactive SSH session:

```sh
uptime
cat /proc/sys/kernel/random/boot_id
dmesg
logread
ls -l /sys/fs/pstore
uci show watchcat
crontab -l
```

If pstore contains crash records, preserve them privately before any cleanup. Absence of records does not rule out a crash. For a longer-term solution, configure OpenWrt's external system log server to an existing trusted receiver and verify reception before relying on it. Local RAM logs disappear at reboot and a small buffer can rotate quickly under beacon/roaming traffic.

References: [OpenWrt Watchcat](https://openwrt.org/docs/guide-user/advanced/watchcat), [OpenWrt logging](https://openwrt.org/docs/guide-user/base-system/log.essentials), [LuCI storage display source](https://github.com/openwrt/luci/blob/openwrt-25.12/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/25_storage.js).

Validation: the PowerShell collector was exercised locally in a short run. The AP-side collector requires SSH and has not been executed against the fleet during this investigation.


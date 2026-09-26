#!/bin/sh
# Stream diagnostics over SSH; writes no files and changes no AP settings.
logger_pid=
cleanup() {
    [ -z "$logger_pid" ] || kill "$logger_pid" 2>/dev/null
}
trap cleanup EXIT
trap 'exit 0' HUP INT TERM
echo '=== INITIAL KERNEL LOG ==='
dmesg
echo '=== SYSTEM LOG STREAM ==='
logread -f &
logger_pid=$!
count=0
while [ "$count" -lt 2880 ]; do
    echo '=== TELEMETRY SAMPLE ==='
    date -u '+%Y-%m-%dT%H:%M:%SZ'
    printf 'boot_id: '; cat /proc/sys/kernel/random/boot_id
    printf 'uptime: '; cat /proc/uptime
    printf 'load: '; cat /proc/loadavg
    grep -E '^(MemAvailable|MemFree|Slab|SUnreclaim|SwapTotal|SwapFree):' /proc/meminfo
    df -k / /tmp
    for zone in /sys/class/thermal/thermal_zone*; do
        [ -r "$zone/temp" ] || continue
        printf '%s ' "$zone"
        cat "$zone/temp"
    done
    echo 'gateway probe:'
    ping -c 1 -W 2 10.99.99.1
    count=$((count + 1))
    sleep 60
done


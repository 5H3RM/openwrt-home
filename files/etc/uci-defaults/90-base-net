#!/bin/sh
# Safe-first setup: VLANs/ports, mgmt DHCP + rescue IP, SSIDs, TLS/NTP.
# WAN+LAN3 = MGMT (untagged 99), LAN1+LAN2 = IoT (untagged 10)
# SSIDs on all radios (no isolation). Mesh comes a few seconds later.

# ---------- EDIT ME ----------
MGMT_VID=99
IOT_VID=10
HOME_VID=30
GUEST_VID=20

HOME_SSID='Loading...'
HOME_KEY='stillloading'
GUEST_SSID='Guest...'
GUEST_KEY='whosinmyhouse'
IOT_SSID='Starlink 5Ghz'
IOT_KEY='NOT4elon#'

NTP1='10.99.99.1'
NTP2='time.cloudflare.com'
NTP3='time.google.com'
# -----------------------------

# Hostname by bridge MAC
BRMAC="$(cat /sys/class/net/br-lan/address 2>/dev/null || cat /sys/class/net/bridge/address 2>/dev/null || echo unknown)"
case "$BRMAC" in
  d8:ec:5e:86:f9:7f) HN='AP-1' ;;
  d8:ec:5e:87:13:ce) HN='AP-2' ;;
  d8:ec:5e:86:f7:bd) HN='AP-3' ;;
  *) HN='AP-unknown' ;;
esac
uci set system.@system[0].hostname="$HN"
uci set system.@system[0].zonename='America/Chicago'
uci set system.@system[0].timezone='CST6CDT,M3.2.0,M11.1.0'
uci set system.ntp=timeserver
uci set system.ntp.enabled='1'
uci -q delete system.ntp.server
uci add_list system.ntp.server="$NTP1"
uci add_list system.ntp.server="$NTP2"
uci add_list system.ntp.server="$NTP3"

# SSH hardening
uci set dropbear.@dropbear[0].PasswordAuth='off'
uci set dropbear.@dropbear[0].RootPasswordAuth='off'

# Radios (no mesh here)
uci set wireless.radio0.country='US'
uci set wireless.radio0.band='5g'
uci set wireless.radio0.channel='36'
uci set wireless.radio0.htmode='HE80'
uci set wireless.radio0.disabled='0'
uci set wireless.radio1.country='US'
uci set wireless.radio1.band='2g'
uci set wireless.radio1.htmode='HE20'
uci set wireless.radio1.disabled='0'
uci set wireless.radio2.country='US'
uci set wireless.radio2.band='5g'
uci set wireless.radio2.htmode='HE80'
uci set wireless.radio2.disabled='0'

# Wipe default ifaces
while uci -q delete wireless.@wifi-iface[0]; do :; done

add_ap() {
  local dev="$1" ssid="$2" key="$3" net="$4" enc="$5"
  uci add wireless wifi-iface
  uci set wireless.@wifi-iface[-1].device="$dev"
  uci set wireless.@wifi-iface[-1].mode='ap'
  uci set wireless.@wifi-iface[-1].ssid="$ssid"
  uci set wireless.@wifi-iface[-1].encryption="$enc"
  uci set wireless.@wifi-iface[-1].key="$key"
  uci set wireless.@wifi-iface[-1].network="$net"
  uci set wireless.@wifi-iface[-1].isolate='0'
}
for dev in radio0 radio1 radio2; do
  add_ap "$dev" "$HOME_SSID"  "$HOME_KEY"  'home'  'sae-mixed'
  add_ap "$dev" "$GUEST_SSID" "$GUEST_KEY" 'guest' 'sae-mixed'
  add_ap "$dev" "$IOT_SSID"   "$IOT_KEY"   'iot'   'psk2'
done

# DSA bridge (NO bat0 here)
uci -q delete network.bridge
uci set network.bridge='device'
uci set network.bridge.name='bridge'
uci set network.bridge.type='bridge'
uci set network.bridge.vlan_filtering='1'
uci set network.bridge.stp='1'
uci add_list network.bridge.ports='wan'
uci add_list network.bridge.ports='lan1'
uci add_list network.bridge.ports='lan2'
uci add_list network.bridge.ports='lan3'

# Clean old VLANs
while uci -q delete network.@bridge-vlan[0]; do :; done

# VLAN 99 MGMT: untagged on WAN + LAN3
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='bridge'
uci set network.@bridge-vlan[-1].vlan="$MGMT_VID"
uci add_list network.@bridge-vlan[-1].ports='wan:u*'
uci add_list network.@bridge-vlan[-1].ports='lan3:u'

# VLAN 10 IoT: untagged on LAN1 + LAN2
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='bridge'
uci set network.@bridge-vlan[-1].vlan="$IOT_VID"
uci add_list network.@bridge-vlan[-1].ports='lan1:u*'
uci add_list network.@bridge-vlan[-1].ports='lan2:u'

# VLAN 30 HOME and 20 GUEST: CPU/bridge only
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='bridge'
uci set network.@bridge-vlan[-1].vlan="$HOME_VID"
uci add_list network.@bridge-vlan[-1].ports='bridge:t'
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='bridge'
uci set network.@bridge-vlan[-1].vlan="$GUEST_VID"
uci add_list network.@bridge-vlan[-1].ports='bridge:t'

# L3 ifaces
uci -q delete network.mgmt
uci set network.mgmt='interface'
uci set network.mgmt.device="bridge.$MGMT_VID"
uci set network.mgmt.proto='dhcp'

# Rescue IP (always reachable even w/o DHCP)
uci set network.mgmt_rescue='interface'
uci set network.mgmt_rescue.device="bridge.$MGMT_VID"
uci set network.mgmt_rescue.proto='static'
uci set network.mgmt_rescue.ipaddr='192.168.99.2'
uci set network.mgmt_rescue.netmask='255.255.255.0'
uci set network.mgmt_rescue.gateway=''

uci -q delete network.iot
uci set network.iot='interface';   uci set network.iot.device="bridge.$IOT_VID";   uci set network.iot.proto='none'
uci -q delete network.home
uci set network.home='interface';  uci set network.home.device="bridge.$HOME_VID"; uci set network.home.proto='none'
uci -q delete network.guest
uci set network.guest='interface'; uci set network.guest.device="bridge.$GUEST_VID"; uci set network.guest.proto='none'

# uHTTPd TLS redirect
uci set uhttpd.main.listen_http='0.0.0.0:80 [::]:80'
uci set uhttpd.main.listen_https='0.0.0.0:443 [::]:443'
uci set uhttpd.main.redirect_https='1'
uci set uhttpd.defaults=cert
uci set uhttpd.defaults.days='397'
uci set uhttpd.defaults.key_type='ec'
uci set uhttpd.defaults.ec_curve='P-256'

# Disable firewall & dnsmasq (pfSense in front)
if /etc/init.d/firewall enabled 2>/dev/null; then /etc/init.d/firewall disable; fi
if /etc/init.d/dnsmasq enabled 2>/dev/null;  then /etc/init.d/dnsmasq disable;  fi

# Enable + start mesh stage with a short delay (same boot, safer)
[ -x /etc/init.d/mesh-stage ] && {
  /etc/init.d/mesh-stage enable
  ( sleep 30; /etc/init.d/mesh-stage start ) >/dev/null 2>&1 &
}

uci commit
exit 0

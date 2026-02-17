#!/bin/bash

# 1. Root Check
if [ "$EUID" -ne 0 ]; then
    echo "[!] Error: Must be run as root."
    exit 1
fi

set -e

# --- [ Settings ] ---
DHCP_CONF="/etc/dhcpcd.conf"
INT_CONF="/etc/network/interfaces"
PING_TARGET="8.8.8.8"

# --- [ 1. Search for Wireless Interface ] ---
WLAN_IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^w' | head -n 1)

if [ -z "$WLAN_IFACE" ]; then
    echo "------------------------------------------------"
    echo "[FAILED] No wireless interface detected."
    echo "Please check your WiFi driver or hardware."
    echo "------------------------------------------------"
    exit 1
fi

echo "[*] Found Wireless Interface: $WLAN_IFACE"

# --- [ 2. Permanent Config Setup ] ---
echo "[*] Optimizing system for persistent connection..."
systemctl enable iwd >/dev/null 2>&1
systemctl enable dhcpcd >/dev/null 2>&1

# Fix dhcpcd.conf (Metric priority)
sed -i '/# Added by setup_wifi/,/nogateway/d' "$DHCP_CONF"
cat <<EOF >> "$DHCP_CONF"

# Added by setup_wifi
interface $WLAN_IFACE
    metric 10
interface vmbr0
    nogateway
EOF

# Comment out interfering gateways
if [ -f "$INT_CONF" ]; then
    sed -i 's/^\s*gateway/# gateway/g' "$INT_CONF"
fi

# --- [ 3. WiFi Connection ] ---
systemctl start iwd
echo "[*] Scanning for networks on $WLAN_IFACE..."
iwctl station "$WLAN_IFACE" scan
sleep 2
iwctl station "$WLAN_IFACE" get-networks
echo "------------------------------------------------"

read -r -p ">> Enter SSID: " SSID
read -r -sp ">> Enter Passphrase: " PASSWORD
echo -e "\n"

echo "[*] Connecting to '$SSID'..."
if ! iwctl --passphrase "$PASSWORD" station "$WLAN_IFACE" connect "$SSID"; then
    echo "------------------------------------------------"
    echo "[FAILED] Connection error. Check SSID/Password."
    echo "------------------------------------------------"
    exit 1
fi

# --- [ 4. IP Assignment & Routing Fix ] ---
echo "[*] Requesting IP and clearing bridge routes..."
ip route del default dev vmbr0 2>/dev/null || true
systemctl restart dhcpcd

# Wait for stabilization
echo "[*] Verifying connection..."
sleep 5

# --- [ 5. Final Ping Test & Workflow Logic ] ---
if ping -c 2 -W 5 "$PING_TARGET" > /dev/null 2>&1; then
    echo "------------------------------------------------"
    echo "[SUCCESS] Internet is working!"
    echo "System will REBOOT in 5 seconds to apply all changes."
    echo "------------------------------------------------"
    sleep 5
    reboot
else
    echo "------------------------------------------------"
    echo "[FAILED] WiFi connected, but Ping to $PING_TARGET failed."
    echo "Possible routing issue or DNS problem."
    echo "------------------------------------------------"
    exit 1
fi

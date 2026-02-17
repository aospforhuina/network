#!/bin/bash

# =================================================================
# Script: setup_wifi.sh (Root Only / No Sudo / TTY Optimized)
# =================================================================

# 1. Strict Root Check (Must be actual root, not just a sudoer)
if [ "$EUID" -ne 0 ]; then
    echo "[!] Error: This script must be run as root."
    echo "    Try switching user: su -"
    exit 1
fi

set -e

# --- [ Settings ] ---
PING_TARGET="8.8.8.8"

# --- [ Functions ] ---

get_tool_path() {
    local tool=$1
    local path
    path=$(command -v "$tool" 2>/dev/null || which "$tool" 2>/dev/null || echo "")
    
    if [ -z "$path" ]; then
        for p in "/usr/bin/$tool" "/usr/sbin/$tool" "/sbin/$tool" "/bin/$tool"; do
            if [ -x "$p" ]; then path=$p; break; fi
        done
    fi

    if [ -z "$path" ]; then
        echo "[!] Error: Tool '$tool' not found. Install it first."
        exit 1
    fi
    echo "$path"
}

get_wifi_interface() {
    local iface
    iface=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^w' | head -n 1)
    if [ -z "$iface" ]; then
        echo "[!] Error: No wireless interface detected."
        exit 1
    fi
    echo "$iface"
}

ensure_service() {
    local service=$1
    echo "[*] Initializing $service..."
    systemctl unmask "$service" >/dev/null 2>&1 || true
    systemctl start "$service" || { echo "[!] Failed to start $service"; exit 1; }
}

# --- [ Main Logic ] ---

# Ensure standard paths are in the environment
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

IWCTL=$(get_tool_path "iwctl")
DHCPCD=$(get_tool_path "dhcpcd")
IP_CMD=$(get_tool_path "ip")

WLAN_IFACE=$(get_wifi_interface)
ensure_service "iwd"

# 2. Scanning (Optional but helpful in TTY)
echo "[*] Scanning for available networks on $WLAN_IFACE..."
$IWCTL station "$WLAN_IFACE" scan
sleep 2
$IWCTL station "$WLAN_IFACE" get-networks
echo "------------------------------------------------"

# 3. User Input
read -r -p ">> Enter SSID: " SSID
if [ -z "$SSID" ]; then echo "[!] SSID required."; exit 1; fi

read -r -sp ">> Enter Passphrase: " PASSWORD
echo -e "\n"

# 4. Connection
$IP_CMD link set "$WLAN_IFACE" up

echo "[*] Attempting connection to '$SSID'..."
if ! $IWCTL --passphrase "$PASSWORD" station "$WLAN_IFACE" connect "$SSID"; then
    echo "[!] Connection failed. Check credentials."
    exit 1
fi

echo "[*] Stabilizing link..."
sleep 4

echo "[*] Requesting IP via dhcpcd..."
# Kill any existing dhcpcd instances on this interface to avoid conflicts
$DHCPCD -k "$WLAN_IFACE" >/dev/null 2>&1 || true
if ! $DHCPCD "$WLAN_IFACE"; then
    echo "[!] DHCP failed."
    exit 1
fi

# 5. Final Test
echo "[*] Testing ping to $PING_TARGET..."
if ping -c 2 -W 5 "$PING_TARGET" > /dev/null 2>&1; then
    echo "[+] ONLINE."
    echo "------------------------------------------------"
    $IP_CMD -4 addr show "$WLAN_IFACE" | grep inet
else
    echo "[!] Link is up but no internet access."
fi

echo "Done."

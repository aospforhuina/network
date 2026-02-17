#!/bin/bash

# =================================================================
# Script: setup_wifi.sh (TTY Optimized)
# Purpose: WiFi automation for Minimal Install (Arch/Debian)
# =================================================================

set -e

# --- [ Settings ] ---
REQUIRED_PKG=("iwd" "dhcpcd")
LOG_FILE="/tmp/wifi_setup.log"
PING_TARGET="8.8.8.8"

# --- [ Functions ] ---

check_dependencies() {
    echo "[*] Verifying tool paths..."
    local TOOLS=("iwctl" "dhcpcd" "ip")
    
    for tool in "${TOOLS[@]}"; do
        # 1. 일반적인 command -v 체크
        # 2. 실패 시 /usr/bin, /usr/sbin, /bin, /sbin 직접 뒤지기
        if ! command -v "$tool" > /dev/null 2>&1 && \
           ! [ -f "/usr/bin/$tool" ] && \
           ! [ -f "/usr/sbin/$tool" ] && \
           ! [ -f "/sbin/$tool" ]; then
            echo "[!] Error: '$tool' not found in standard paths."
            echo "    Current PATH: $PATH"
            exit 1
        fi
    done
    echo "[+] All tools found."
}


get_wifi_interface() {
    # Detects interface starting with 'w' (e.g., wlan0, wlp2s0)
    local iface=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^w' | head -n 1)
    if [ -z "$iface" ]; then
        echo "[!] Error: No wireless interface detected."
        exit 1
    fi
    echo "$iface"
}

ensure_service() {
    local service=$1
    if ! systemctl is-active --quiet "$service"; then
        echo "[*] Starting $service..."
        sudo systemctl start "$service" || { echo "[!] Failed to start $service"; exit 1; }
    fi
}

# --- [ Main Logic ] ---

check_dependencies
WLAN_IFACE=$(get_wifi_interface)
echo "[+] Detected Interface: $WLAN_IFACE"

# User Input
echo -n ">> Enter WiFi SSID: "
read SSID
echo -n ">> Enter Passphrase: "
read -s PASSWORD
echo -e "\n"

# Connection Process
ensure_service "iwd"
sudo ip link set "$WLAN_IFACE" up

echo "[*] Connecting to '$SSID'..."
if ! iwctl --passphrase "$PASSWORD" station "$WLAN_IFACE" connect "$SSID"; then
    echo "[!] Connection Failed: Check SSID/Password."
    exit 1
fi

echo "[*] Requesting IP via DHCP ($WLAN_IFACE)..."
if ! sudo dhcpcd "$WLAN_IFACE"; then
    echo "[!] DHCP Failed!"
    exit 1
fi

# Internet Verification
echo "[*] Verifying internet connectivity ($PING_TARGET)..."
if ! ping -c 3 -W 2 $PING_TARGET > "$LOG_FILE" 2>&1; then
    echo "[!] Network is UP, but no response from $PING_TARGET."
    cat "$LOG_FILE"
    exit 1
fi

if grep -qiE "unreachable|100% packet loss" "$LOG_FILE"; then
    echo "[!] Error: Network Unreachable."
    echo "--- Debug Log ---"
    cat "$LOG_FILE"
    exit 1
else
    echo "[+] SUCCESS: Internet connection established!"
    rm -f "$LOG_FILE"
fi

# Final Summary
echo "------------------------------------------------"
echo "IP Address Info:"
ip -4 addr show "$WLAN_IFACE" | grep inet || echo "No IP assigned"
echo "Done."
echo "------------------------------------------------"

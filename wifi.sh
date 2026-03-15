#!/bin/bash

# 0. 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[!] Error: Must be run as root."
    exit 1
fi

set -e

# --- [ 함수: 환경 및 패키지 검사 ] ---
check_environment() {
    echo "[*] Checking system dependencies..."
    local required_pkgs=("network-manager" "iproute2" "wireless-tools")
    local missing_pkgs=()

    for pkg in "${required_pkgs[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        echo "[!] Missing: ${missing_pkgs[*]}"
        read -r -p "[?] Install missing packages? (y/n): " choice
        [[ "$choice" == "y" ]] && apt update && apt install -y "${missing_pkgs[@]}" || exit 1
    fi

    systemctl is-active --quiet NetworkManager || systemctl start NetworkManager
}

# --- [ 함수: 네트워크 스캔 ] ---
list_networks() {
    echo "[*] Scanning for available networks..."
    nmcli device wifi rescan
    echo -e "SSID\t\tSIGNAL\tSECURITY"
    nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | awk -F: '{printf "%-20s\t%s%%\t%s\n", $1, $2, $3}'
}

# --- [ 함수: 네트워크 초기화 ] ---
reset_network() {
    echo "[!] Critical Error: Routing failed. Resetting..."
    nmcli -g connection.id connection show --active | grep -E '^predefined-ssid' | xargs -I {} nmcli connection delete {}
    systemctl restart NetworkManager
    exit 1
}

# 1. 환경 검사 및 WiFi 인터페이스 확인
check_environment
WLAN_IFACE=$(nmcli -t -f DEVICE,TYPE device | grep ":wifi" | cut -d: -f1 | head -n 1)
[ -z "$WLAN_IFACE" ] && { echo "[!] No wifi device."; exit 1; }

# 2. 네트워크 선택 및 연결
list_networks
echo "------------------------------------------------"
read -r -p ">> Enter SSID: " SSID
read -r -sp ">> Enter Passphrase: " PASSWORD
echo -e "\n"

nmcli connection delete "predefined-ssid-$SSID" >/dev/null 2>&1 || true

echo "[*] Connecting to '$SSID'..."
nmcli device wifi connect "$SSID" password "$PASSWORD" ifname "$WLAN_IFACE"
nmcli connection modify "predefined-ssid-$SSID" ipv4.route-metric 10

# 3. 브리지 설정 (존재 시)
if nmcli connection show vmbr0 >/dev/null 2>&1; then
    nmcli connection modify vmbr0 ipv4.never-default yes
    nmcli connection up vmbr0
fi

# 4. 라우팅 검증
echo "[*] Verifying connectivity..."
sleep 5
if ! ping -c 2 -W 5 8.8.8.8 > /dev/null 2>&1; then
    reset_network
else
    echo "[SUCCESS] Internet is active."
fi

#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "[!] Error: Must be run as root."
    exit 1
fi

set -e

# --- [ 함수: 네트워크 초기화 ] ---
reset_network() {
    echo "[!] Critical Error: Routing failed. Resetting network configurations..."
    # 1. 모든 WiFi 연결 삭제
    nmcli -g connection.id connection show --active | grep -E '^predefined-ssid' | xargs -I {} nmcli connection delete {}
    # 2. 라우팅 로그 저장
    ip route > route.txt
    echo "[*] Current routing table saved to route.txt"
    # 3. 네트워크 매니저 재시작
    systemctl restart NetworkManager
    echo "[*] NetworkManager restarted. Please run script again."
    exit 1
}

# --- [ 1. Setup ] ---
systemctl enable NetworkManager >/dev/null 2>&1
systemctl start NetworkManager

# --- [ 2. WiFi Interface ] ---
WLAN_IFACE=$(nmcli -t -f DEVICE,TYPE device | grep ":wifi" | cut -d: -f1 | head -n 1)
[ -z "$WLAN_IFACE" ] && { echo "[!] No wifi device."; exit 1; }

# --- [ 3. Connection ] ---
read -r -p ">> Enter SSID: " SSID
read -r -sp ">> Enter Passphrase: " PASSWORD
echo -e "\n"

# 기존에 같은 이름의 연결이 있다면 삭제하고 새로 생성
nmcli connection delete "predefined-ssid-$SSID" >/dev/null 2>&1 || true

echo "[*] Connecting to '$SSID'..."
nmcli device wifi connect "$SSID" password "$PASSWORD" ifname "$WLAN_IFACE"
nmcli connection modify "predefined-ssid-$SSID" ipv4.route-metric 10

# 브리지 설정
if nmcli connection show vmbr0 >/dev/null 2>&1; then
    nmcli connection modify vmbr0 ipv4.never-default yes
    nmcli connection up vmbr0
fi

# --- [ 4. Routing Validation ] ---
echo "[*] Verifying connectivity..."
sleep 5

# 핑 테스트 실패 시 바로 reset_network 호출
if ! ping -c 2 -W 5 8.8.8.8 > /dev/null 2>&1; then
    reset_network
else
    echo "[SUCCESS] Internet is active."
fi

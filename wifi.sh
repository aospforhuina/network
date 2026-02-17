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
#!/bin/bash

# =================================================================
# Script: setup_wifi.sh (Root Only / TTY Optimized)
# Description: Automated WiFi setup without sudo for root shell
# =================================================================

# 1. 루트 권한 체크
if [ "$EUID" -ne 0 ]; then
    echo "[!] Error: Please run this script as root."
    exit 1
fi

set -e

# --- [ Settings ] ---
LOG_FILE="/tmp/wifi_setup.log"
PING_TARGET="8.8.8.8"

# --- [ Functions ] ---

# 도구의 경로를 찾거나 직접 지정 (iwd 설치되어 있는데 못 찾는 문제 해결)
check_tool() {
    local tool=$1
    if command -v "$tool" > /dev/null 2>&1; then
        return 0
    elif [ -f "/usr/bin/$tool" ] || [ -f "/usr/sbin/$tool" ] || [ -f "/sbin/$tool" ]; then
        return 0
    else
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
         systemctl start "$service" || { echo "[!] Failed to start $service"; exit 1; }
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
 ip link set "$WLAN_IFACE" up

echo "[*] Connecting to '$SSID'..."
if ! iwctl --passphrase "$PASSWORD" station "$WLAN_IFACE" connect "$SSID"; then
#!/bin/bash

# =================================================================
# Script: setup_wifi.sh (Root Only / TTY Optimized)
# Description: Automated WiFi setup without  for root shell
# =================================================================

# 1. 루트 권한 체크
if [ "$EUID" -ne 0 ]; then
    echo "[!] Error: Please run this script as root."
    exit 1
fi

set -e

# --- [ Settings ] ---
LOG_FILE="/tmp/wifi_setup.log"
PING_TARGET="8.8.8.8"

# --- [ Functions ] ---

# 도구의 경로를 찾거나 직접 지정 (iwd 설치되어 있는데 못 찾는 문제 해결)
check_tool() {
    local tool=$1
    if command -v "$tool" > /dev/null 2>&1; then
        return 0
    elif [ -f "/usr/bin/$tool" ] || [ -f "/usr/sbin/$tool" ] || [ -f "/sbin/$tool" ]; then
        return 0
    else
        echo "[!] Error: Tool '$tool' not found. Check if it's installed."
        exit 1
    fi
}

get_wifi_interface() {
    # w로 시작하는 무선 인터페이스 감지 (wlan0, wlp2s0 등)
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
        systemctl start "$service" || { echo "[!] Failed to start $service"; exit 1; }
    fi
}

# --- [ Main Logic ] ---

echo "[*] Verifying environment..."
check_tool "iwctl"
check_tool "dhcpcd"
check_tool "ip"

WLAN_IFACE=$(get_wifi_interface)
echo "[+] Detected Interface: $WLAN_IFACE"

# 사용자 입력 (TTY 안전 모드)
echo -n ">> Enter WiFi SSID: "
read SSID
echo -n ">> Enter Passphrase: "
read -s PASSWORD
echo -e "\n"

# 연결 프로세스
ensure_service "iwd"
ip link set "$WLAN_IFACE" up

echo "[*] Connecting to '$SSID'..."
# iwctl 설치되어 있는데 못 찾는 경우를 대비해 직접 호출
if ! iwctl --passphrase "$PASSWORD" station "$WLAN_IFACE" connect "$SSID"; then
    echo "[!] Connection Failed: Check SSID/Password or Signal."
    exit 1
fi

echo "[*] Requesting IP via DHCP ($WLAN_IFACE)..."
if ! dhcpcd "$WLAN_IFACE"; then
    echo "[!] DHCP Failed!"
    exit 1
fi

# 인터넷 연결 최종 검증
echo "[*] Verifying internet connectivity ($PING_TARGET)..."
if ! ping -c 3 -W 2 $PING_TARGET > "$LOG_FILE" 2>&1; then
    echo "[!] Physical link is UP, but no response from $PING_TARGET."
    cat "$LOG_FILE"
    exit 1
fi

# 로그 내 'unreachable' 또는 '100% loss' 검색
if grep -qiE "unreachable|100% packet loss" "$LOG_FILE"; then
    echo "[!] Error: Network Unreachable."
    echo "--- Debug Log ---"
    cat "$LOG_FILE"
    exit 1
else
    echo "[+] SUCCESS: Internet connection established!"
    rm -f "$LOG_FILE"
fi

# --- [ Result ] ---
echo "------------------------------------------------"
echo "IP Address Details:"
ip -4 addr show "$WLAN_IFACE" | grep inet || echo "No IP assigned"
echo "Done."
echo "------------------------------------------------"

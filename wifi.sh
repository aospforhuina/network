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
#!/bin/bash

# =================================================================
# Script: setup_wifi.sh (Root Only / TTY Optimized)
# Description: Automated WiFi setup for Minimal Installs
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

# 도구 존재 여부 확인 및 경로 반환
get_tool_path() {
    local tool=$1
    local path
    path=$(command -v "$tool" || which "$tool" 2>/dev/null || echo "")
    
    if [ -z "$path" ]; then
        # 표준 경로 직접 검색
        for p in "/usr/bin/$tool" "/usr/sbin/$tool" "/sbin/$tool" "/bin/$tool"; do
            if [ -f "$p" ]; then path=$p; break; fi
        done
    fi

    if [ -z "$path" ]; then
        echo "[!] Error: Tool '$tool' not found. Please install it first."
        exit 1
    fi
    echo "$path"
}

get_wifi_interface() {
    # w로 시작하는 무선 인터페이스 감지 (wlan0, wlp2s0 등)
    local iface
    iface=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^w' | head -n 1)
    if [ -z "$iface" ]; then
        echo "[!] Error: No wireless interface detected. Is the driver loaded?"
        exit 1
    fi
    echo "$iface"
}

ensure_service() {
    local service=$1
    echo "[*] Ensuring $service is running..."
    systemctl unmask "$service" >/dev/null 2>&1 || true
    systemctl start "$service" || { echo "[!] Failed to start $service"; exit 1; }
}

# --- [ Main Logic ] ---

echo "------------------------------------------------"
echo "  WiFi Setup Tool (Minimal/TTY)"
echo "------------------------------------------------"

# 도구 경로 확보
IWCTL=$(get_tool_path "iwctl")
DHCPCD=$(get_tool_path "dhcpcd")
IP_CMD=$(get_tool_path "ip")

WLAN_IFACE=$(get_wifi_interface)
echo "[+] Detected Interface: $WLAN_IFACE"

# 서비스 활성화
ensure_service "iwd"

# 사용자 입력
read -p ">> Enter WiFi SSID: " SSID
if [ -z "$SSID" ]; then echo "[!] SSID cannot be empty."; exit 1; fi

read -sp ">> Enter Passphrase: " PASSWORD
echo -e "\n"

# 인터페이스 활성화
$IP_CMD link set "$WLAN_IFACE" up

echo "[*] Connecting to '$SSID'..."
# iwctl을 사용하여 연결 시도
if ! $IWCTL --passphrase "$PASSWORD" station "$WLAN_IFACE" connect "$SSID"; then
    echo "[!] Connection Failed: Check SSID/Password or Signal strength."
    exit 1
fi

# 연결 완료 후 인터페이스 안정화를 위해 잠시 대기
echo "[*] Waiting for link to stabilize (5s)..."
sleep 5

echo "[*] Requesting IP via DHCP..."
# 이미 실행 중인 dhcpcd가 있을 경우를 대비해 -n(rebind) 또는 재시작 권장
# 여기서는 가장 확실한 방식인 '새로 시작'을 위해 기존 프로세스 영향 없이 실행
$DHCPCD -k "$WLAN_IFACE" >/dev/null 2>&1 || true
if ! $DHCPCD "$WLAN_IFACE"; then
    echo "[!] DHCP Failed! You might need to check dhcpcd logs."
    exit 1
fi

# 인터넷 연결 최종 검증
echo "[*] Verifying internet connectivity..."
if ping -c 3 -W 5 $PING_TARGET > /dev/null 2>&1; then
    echo "[+] SUCCESS: Internet connection established!"
else
    echo "[!] Physical link is UP, but cannot reach $PING_TARGET."
    echo "[?] Hint: Check your DNS (/etc/resolv.conf) or Gateway."
    exit 1
fi

# --- [ Result ] ---
echo "------------------------------------------------"
echo "Connection Summary:"
$IP_CMD -4 addr show "$WLAN_IFACE" | grep inet || echo "No IP assigned"
echo "------------------------------------------------"
echo "Done. Happy Browsing!"

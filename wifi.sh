#!/bin/bash

# [1] 무선 인터페이스 자동 탐색
INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')

if [ -z "$INTERFACE" ]; then
    echo "Error: 무선 인터페이스를 찾을 수 없습니다. 하드웨어 상태를 확인하세요."
    exit 1
fi

echo "Detected Interface: $INTERFACE"

HOOK_DIR="/lib/dhcpcd/dhcpcd-hooks"
HOOK_FILE="$HOOK_DIR/99-set-metric"
TARGET_IP="8.8.8.8"

# [2] 환경 설정
mkdir -p "$HOOK_DIR"

cat <<EOF > "$HOOK_FILE"
if [ "\$interface" = "$INTERFACE" ]; then
    ip route del default dev $INTERFACE 2>/dev/null
    ip route add default dev $INTERFACE metric 100
fi
EOF
chmod +x "$HOOK_FILE"

# [3] 서비스 및 연결
systemctl enable iwd
systemctl enable dhcpcd
systemctl restart iwd dhcpcd

echo "Scanning..."
iwctl station $INTERFACE scan
iwctl station $INTERFACE get-networks

read -p "SSID: " SSID
read -s -p "Password: " PASSPHRASE
echo ""

iwctl --passphrase "$PASSPHRASE" station $INTERFACE connect "$SSID"
sleep 3

# [4] 결과 리포트
echo "--- Connection Report ---"
echo "Status: $(iwctl station $INTERFACE show | grep State | awk '{print $2}')"
ip route | grep default
ping -c 3 $TARGET_IP > /dev/null && echo "Result: Internet Online." || echo "Result: Internet Offline."

#!/bin/bash

# 설정 변수
INTERFACE="wlan0"
HOOK_FILE="/lib/dhcpcd/dhcpcd-hooks/99-set-metric"
TARGET_IP="8.8.8.8"

echo "[1/3] Configuring Persistence..."
sudo systemctl enable iwd
sudo systemctl enable dhcpcd

# 메트릭 강제 고정 훅 생성
cat <<EOF | sudo tee $HOOK_FILE > /dev/null
if [ "\$interface" = "$INTERFACE" ]; then
    # 기존 default 게이트웨이가 꼬였을 경우 제거 후 다시 설정
    ip route del default dev $INTERFACE 2>/dev/null
    ip route add default dev $INTERFACE metric 100
fi
EOF
sudo chmod +x $HOOK_FILE

echo "[2/3] Connecting to network..."
# IWD를 이용한 연결 시도 (최초 1회 실행 시 암호 저장됨)
# 이미 저장된 네트워크가 있다면 별도 입력 없이도 자동 연결됨
read -p "Enter SSID: " SSID
read -s -p "Enter Password: " PASSPHRASE
echo ""

iwctl --passphrase "$PASSPHRASE" station $INTERFACE connect "$SSID"
sleep 5

echo "[3/3] Verifying L3 Connectivity and Routing..."
# 연결 상태 및 경로 검증
if [ "$(iwctl station $INTERFACE show | grep State | awk '{print $2}')" == "connected" ]; then
    # 핑 테스트
    if ping -c 3 $TARGET_IP > /dev/null; then
        echo "========================================="
        echo "SUCCESS: Internet is active (Metric 100)."
        echo "========================================="
    else
        echo "FAILED: Connection established but Ping failed."
        echo "Current Route Table:"
        ip route
        exit 1
    fi
else
    echo "FAILED: Could not connect to $SSID."
    exit 1
fi

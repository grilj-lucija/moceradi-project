#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

ENV_FILE="mobile/.env"
DEVICE="${1:-}"
shift || true

detect_ip() {
  local iface ip=""
  iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
  if [ -n "${iface:-}" ]; then
    ip=$(ipconfig getifaddr "$iface" 2>/dev/null || true)
  fi
  if [ -z "$ip" ]; then
    for i in en0 en1 en2 en3 en4 bridge100; do
      ip=$(ipconfig getifaddr "$i" 2>/dev/null || true)
      [ -n "$ip" ] && break
    done
  fi
  echo "$ip"
}

set_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
    sed -i.bak "s|^${key}=.*|${key}=${val}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
  else
    printf '%s=%s\n' "$key" "$val" >> "$ENV_FILE"
  fi
}

IP="$(detect_ip)"
if [ -z "$IP" ]; then
  echo "[run-mobile] Could not detect a LAN IP. Are you connected to a network/hotspot?" >&2
  exit 1
fi
echo "[run-mobile] Detected host IP: $IP"

if [ ! -f "$ENV_FILE" ] && [ -f "mobile/.env.example" ]; then
  cp "mobile/.env.example" "$ENV_FILE"
fi

set_env "USE_MOCK_DATA" "false"
set_env "MQTT_HOST" "$IP"
set_env "MQTT_PORT" "1883"
set_env "FOODAI_BASE_URL" "http://${IP}:8000"
echo "[run-mobile] Updated $ENV_FILE to point services at $IP"

check() {
  local name="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "  ok   $name"
  else
    echo "  WARN $name not reachable (is ./start.sh running? firewall?)"
  fi
}

echo "[run-mobile] Checking services on $IP ..."
check "FoodAI  http://${IP}:8000" "curl -s -m 3 -o /dev/null http://${IP}:8000/docs"
check "MQTT    ${IP}:1883" "nc -z -G 3 ${IP} 1883"
check "Web     http://${IP}:3000" "curl -s -m 3 -o /dev/null http://${IP}:3000"

cd mobile
if [ -n "$DEVICE" ]; then
  echo "[run-mobile] flutter run -d $DEVICE $*"
  exec flutter run -d "$DEVICE" "$@"
else
  echo "[run-mobile] No device given; running 'flutter run' (Flutter will prompt)."
  exec flutter run "$@"
fi

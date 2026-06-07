#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f .env ] && [ -f .env.example ]; then
  echo "[start] .env not found — creating from .env.example (fill in real values for full functionality)."
  cp .env.example .env
fi

if [ ! -f scraper/.env ]; then
  echo "[start] scraper/.env not found — creating an empty one so the stack can start."
  touch scraper/.env
fi

COMPOSE_ARGS=()
RUN_MOBILE=0
MOBILE_ARGS=()

if [ "${WITH_MOBILE:-}" = "1" ]; then
  COMPOSE_ARGS+=(--profile mobile)
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --full|--with-mobile)
      echo "[start] Including the mobile APK builder image (this can take several minutes)."
      COMPOSE_ARGS+=(--profile mobile)
      shift
      ;;
    --run-mobile|-m)
      RUN_MOBILE=1
      shift
      MOBILE_ARGS=("$@")
      break
      ;;
    *)
      echo "[start] Unknown option: $1" >&2
      echo "[start] Usage: ./start.sh [--full] [--run-mobile [device] [flutter args...]]" >&2
      exit 2
      ;;
  esac
done

echo "[start] Building and starting the Health App system..."
docker compose ${COMPOSE_ARGS[@]+"${COMPOSE_ARGS[@]}"} up --build -d

WEB_URL="http://localhost:3000"

echo ""
echo "[start] System is up:"
echo "  Web app    -> $WEB_URL"
echo "  FoodAI API -> http://localhost:8000"
echo "  MQTT       -> tcp://localhost:1883 (mqtt), ws://localhost:9001 (websockets)"
if [ ${#COMPOSE_ARGS[@]} -gt 0 ]; then
  echo "  Mobile APK -> http://localhost:8080"
fi
echo ""
echo "[start] Logs:  docker compose logs -f"
echo "[start] Stop:  docker compose down"

if [ "$RUN_MOBILE" -eq 0 ]; then
  if command -v open >/dev/null 2>&1; then
    open "$WEB_URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$WEB_URL"
  elif command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile Start-Process "$WEB_URL" >/dev/null 2>&1 || true
  fi
fi

if [ "$RUN_MOBILE" -eq 1 ]; then
  echo ""
  echo "[start] Launching mobile app via run-mobile.sh ..."
  exec ./run-mobile.sh ${MOBILE_ARGS[@]+"${MOBILE_ARGS[@]}"}
fi

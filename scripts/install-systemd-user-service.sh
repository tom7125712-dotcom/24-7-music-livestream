#!/bin/sh
set -eu

SERVICE_NAME="${SERVICE_NAME:-music-livestream}"
SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/${SERVICE_NAME}.service"
REPO_DIR=$(pwd)

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl is required for service mode. Use docker compose up -d --build instead." >&2
  exit 2
fi

if [ ! -f .env ]; then
  echo ".env was not found. Create it before installing the service." >&2
  exit 2
fi

mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=24/7 Music Livestream
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${REPO_DIR}
ExecStart=/bin/sh ${REPO_DIR}/scripts/run-forever.sh
Restart=always
RestartSec=${RESTART_DELAY:-10}
TimeoutStopSec=30
KillSignal=SIGTERM

[Install]
WantedBy=default.target
EOF

if command -v loginctl >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then
  sudo loginctl enable-linger "$USER" >/dev/null 2>&1 || true
fi

systemctl --user daemon-reload
systemctl --user enable --now "${SERVICE_NAME}.service"
systemctl --user restart "${SERVICE_NAME}.service"
systemctl --user --no-pager --full status "${SERVICE_NAME}.service"

#!/usr/bin/env bash
set -euo pipefail
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
umask 077

if [[ $# -ne 0 ]]; then
  echo "Usage: $0 (enter the VLESS link when prompted)" >&2
  exit 1
fi

for cmd in docker uv; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing $cmd. Install Docker through bootstrap/ubuntu.sh and apply Home Manager for uv." >&2
    exit 1
  fi
done
docker info >/dev/null
docker compose version >/dev/null

CONFIG_DIR="$HOME/opt/xray"
if [[ -e "$CONFIG_DIR/config.json" || -e "$CONFIG_DIR/compose.yaml" ]]; then
  read -r -p "Replace the existing Xray config and container (keeping a backup)? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 0
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT
read -r -p "VLESS link: " VLESS_LINK
printf '%s' "$VLESS_LINK" \
  | uv run --no-project --offline "$(dirname "$0")/vless-config.py" > "$WORK_DIR/config.json"
unset VLESS_LINK

IMAGE="ghcr.io/xtls/xray-core:26.7.28"
# Match the host UID so the non-root container can read the mode-600 config.
docker pull "$IMAGE"
docker run --rm --network none --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$WORK_DIR/config.json,dst=/etc/xray/config.json,readonly" \
  "$IMAGE" run -test -config /etc/xray/config.json

cat > "$WORK_DIR/compose.yaml" <<EOF
name: dotfiles-xray
services:
  xray:
    image: $IMAGE
    user: "$(id -u):$(id -g)"
    command: ["run", "-config", "/etc/xray/config.json"]
    restart: unless-stopped
    read_only: true
    cap_drop: [ALL]
    security_opt: [no-new-privileges:true]
    ports:
      - "127.0.0.1:2080:2080/tcp"
      - "127.0.0.1:2080:2080/udp"
    volumes:
      - ./config.json:/etc/xray/config.json:ro
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
EOF

mkdir -p "$CONFIG_DIR"
if [[ -e "$CONFIG_DIR/config.json" || -e "$CONFIG_DIR/compose.yaml" ]]; then
  BACKUP_DIR="$(mktemp -d "$CONFIG_DIR/backup.XXXXXX")"
  for file in config.json compose.yaml; do
    if [[ -e "$CONFIG_DIR/$file" ]]; then
      cp -p "$CONFIG_DIR/$file" "$BACKUP_DIR/"
    fi
  done
  echo "Previous configuration saved to $BACKUP_DIR"
fi
install -m 600 "$WORK_DIR/config.json" "$CONFIG_DIR/config.json"
install -m 600 "$WORK_DIR/compose.yaml" "$CONFIG_DIR/compose.yaml"
docker compose -f "$CONFIG_DIR/compose.yaml" up -d --force-recreate --wait

echo "Xray v26.7.28 is configured. SOCKS5: 127.0.0.1:2080"
echo "Config and Compose file: $CONFIG_DIR"

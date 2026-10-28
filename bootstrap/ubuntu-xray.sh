#!/usr/bin/env bash
set -euo pipefail
umask 077

if [[ $# -eq 1 && ( "$1" == --help || "$1" == -h ) ]]; then
  echo "Usage: $0 [config.json]"
  echo "Default config: $HOME/opt/xray/config.json"
  exit 0
fi
if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [config.json]" >&2
  exit 1
fi

CONFIG_DIR="$HOME/opt/xray"
SOURCE_CONFIG="${1:-$CONFIG_DIR/config.json}"
if [[ ! -f "$SOURCE_CONFIG" || ! -r "$SOURCE_CONFIG" ]]; then
  echo "Config not found or unreadable: $SOURCE_CONFIG" >&2
  echo "Usage: $0 [config.json]" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Missing Docker. Install it through bootstrap/ubuntu.sh." >&2
  exit 1
fi
docker info >/dev/null
docker compose version >/dev/null

WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT
install -m 600 "$SOURCE_CONFIG" "$WORK_DIR/config.json"

IMAGE="ghcr.io/xtls/xray-core:latest"
docker pull "$IMAGE"
# Match the host UID so the non-root container can read the mode-600 config.
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

if ! cmp -s "$WORK_DIR/config.json" "$CONFIG_DIR/config.json" \
  || ! cmp -s "$WORK_DIR/compose.yaml" "$CONFIG_DIR/compose.yaml"; then
  if [[ -e "$CONFIG_DIR/config.json" || -e "$CONFIG_DIR/compose.yaml" ]]; then
    read -r -p "Replace the existing Xray files (keeping a backup)? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || exit 0
    BACKUP_DIR="$(mktemp -d "$CONFIG_DIR/backup.XXXXXX")"
    for file in config.json compose.yaml; do
      if [[ -e "$CONFIG_DIR/$file" ]]; then
        cp -p "$CONFIG_DIR/$file" "$BACKUP_DIR/"
      fi
    done
    echo "Previous configuration saved to $BACKUP_DIR"
  fi
  mkdir -p "$CONFIG_DIR"
  for file in config.json compose.yaml; do
    if ! cmp -s "$WORK_DIR/$file" "$CONFIG_DIR/$file"; then
      install -m 600 "$WORK_DIR/$file" "$CONFIG_DIR/$file"
    fi
  done
fi
# Recreate to apply edits made directly to ~/opt/xray/config.json as well.
docker compose -f "$CONFIG_DIR/compose.yaml" up -d --force-recreate --wait

echo "Xray ($IMAGE) started. Published ports: 127.0.0.1:2080 (TCP/UDP)."
echo "Config and Compose file: $CONFIG_DIR"

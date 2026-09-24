#!/usr/bin/env bash
set -euo pipefail

commands=(
  nvim
  tmux
  fastfetch
  psql
  rg
  fd
  fzf
  jq
  uv
  lazygit
  node
  pnpm
  go
  golangci-lint
  kubectl
  gh
  sesh
  atuin
)

for cmd in "${commands[@]}"; do
  command -v "$cmd" >/dev/null
  echo "OK: $cmd"
done

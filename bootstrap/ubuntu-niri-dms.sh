#!/usr/bin/env bash
set -euo pipefail

# Use the system graphics stack for the compositor and shell on Ubuntu.
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy

. /etc/os-release
if [[ "$ID" != ubuntu ]] || ! dpkg --compare-versions "$VERSION_ID" ge 26.04; then
  echo "This installer supports Ubuntu 26.04 or newer." >&2
  exit 1
fi

sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:avengemedia/danklinux
sudo add-apt-repository -y ppa:avengemedia/dms
sudo apt update
sudo apt install -y niri dms fuzzel

# The packages enable DMS and dsearch globally, which also starts them in GDM's
# greeter account. Keep them scoped to this user's sessions instead.
sudo systemctl --global disable dms.service dsearch.service
systemctl --user daemon-reload
systemctl --user add-wants niri.service dms.service
systemctl --user enable dsearch.service

echo "niri and DMS are installed. Log out and select Niri in GDM."
echo "Your existing ~/.config/niri/config.kdl is unchanged."

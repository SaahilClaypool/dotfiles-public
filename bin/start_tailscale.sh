#! /bin/bash
set -e
set -o pipefail

sudo whoami

if [ -x tailscale ]; then
    curl -fsSL https://tailscale.com/install.sh | sh
    exit
fi

service ssh start
tailscaled &
disown
tailscale up --shields-up=false

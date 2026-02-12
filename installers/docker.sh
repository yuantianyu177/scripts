#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/env.sh"

DOCKER_DOWNLOAD_BASE="https://download.docker.com/linux/static/stable"

# Map uname -m to Docker's architecture naming
detect_arch() {
  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64)       echo "x86_64" ;;
    aarch64)      echo "aarch64" ;;
    armv7l)       echo "armhf" ;;
    armv6l)       echo "armel" ;;
    ppc64le)      echo "ppc64le" ;;
    s390x)        echo "s390x" ;;
    *)
      echo "Unsupported architecture: $arch" >&2
      exit 1
      ;;
  esac
}

# Fetch available versions from the download page
fetch_versions() {
  local arch=$1
  local url="${DOCKER_DOWNLOAD_BASE}/${arch}/"
  curl -fsSL "$url" \
    | grep -oP 'href="docker-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tgz")' \
    | sort -V
}

ARCH=$(detect_arch)
echo "Detected architecture: $ARCH"
echo ""
echo "Fetching available Docker versions..."

VERSIONS=$(fetch_versions "$ARCH")
if [[ -z "$VERSIONS" ]]; then
  echo "Failed to fetch version list" >&2
  exit 1
fi

LATEST=$(echo "$VERSIONS" | tail -n1)

# Display recent versions
echo ""
echo "Available versions (latest 15):"
echo "$VERSIONS" | tail -n15 | nl -ba
echo ""

read -rp "Enter version to install [default: $LATEST]: " SELECTED_VERSION
SELECTED_VERSION=${SELECTED_VERSION:-$LATEST}

# Validate selection
if ! echo "$VERSIONS" | grep -qx "$SELECTED_VERSION"; then
  echo "Invalid version: $SELECTED_VERSION" >&2
  exit 1
fi

DOWNLOAD_URL="${DOCKER_DOWNLOAD_BASE}/${ARCH}/docker-${SELECTED_VERSION}.tgz"
echo ""
echo "Download URL: $DOWNLOAD_URL"
echo "Installing Docker $SELECTED_VERSION ($ARCH)..."

# Download and extract
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fSL "$DOWNLOAD_URL" -o "$TMPDIR/docker.tgz"
tar -xzf "$TMPDIR/docker.tgz" -C "$TMPDIR"

# Install binaries
sudo cp "$TMPDIR"/docker/* /usr/bin/

# Create docker group if not exists
if ! getent group docker >/dev/null 2>&1; then
  sudo groupadd docker
fi

# Add current user to docker group
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
fi

# Install systemd service if systemd is available
if command_exists systemctl; then
  if [[ ! -f /etc/systemd/system/docker.service ]]; then
    sudo tee /etc/systemd/system/docker.service >/dev/null <<'EOF'
[Unit]
Description=Docker Application Container Engine
After=network-online.target firewalld.service containerd.service
Wants=network-online.target containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF
  fi

  if [[ ! -f /etc/systemd/system/containerd.service ]]; then
    sudo tee /etc/systemd/system/containerd.service >/dev/null <<'EOF'
[Unit]
Description=containerd container runtime
After=network.target

[Service]
ExecStart=/usr/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
  fi

  sudo systemctl daemon-reload
  sudo systemctl enable --now containerd docker
fi

print 0 "Docker $SELECTED_VERSION installed successfully!
Binary path: /usr/bin/docker
Run 'docker version' to verify.
Note: Log out and back in for docker group to take effect."

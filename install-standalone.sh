#!/bin/bash
# systemd-swap standalone installer
set -e

if [ "$EUID" -ne 0 ]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

RELEASE_URL="https://github.com/washosk/systemd-swap/releases/download/v1.0.0"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "📦 Installing systemd-swap..."

# Create directories
mkdir -p /usr/local/bin /etc/systemd /usr/lib/systemd/system

# Download files if not available locally
if [ ! -f "./systemd-swap" ]; then
   echo "📥 Downloading systemd-swap binary..."
   curl -fsSL "$RELEASE_URL/systemd-swap-1.0.0-linux-amd64.tar.gz" | tar xzf - -C "$TMPDIR"
   SOURCE_DIR="$TMPDIR/systemd-swap-1.0.0"
   BIN_PATH="$SOURCE_DIR/usr/local/bin/systemd-swap"
   CONF_PATH="$SOURCE_DIR/etc/systemd/swap.conf"
   SERVICE_PATH="$SOURCE_DIR/usr/lib/systemd/system/systemd-swap.service"
else
   SOURCE_DIR="."
   BIN_PATH="$SOURCE_DIR/systemd-swap"
   CONF_PATH="$SOURCE_DIR/swap.conf"
   SERVICE_PATH="$SOURCE_DIR/systemd-swap.service"
fi

# Install manager script
echo "📝 Installing manager script..."
cp "$BIN_PATH" /usr/local/bin/systemd-swap
chmod 0755 /usr/local/bin/systemd-swap

# Install config
echo "⚙️  Installing configuration..."
cp "$CONF_PATH" /etc/systemd/swap.conf
chmod 0644 /etc/systemd/swap.conf

# Install systemd service
echo "🔧 Installing systemd service..."
cp "$SERVICE_PATH" /usr/lib/systemd/system/systemd-swap.service
chmod 0644 /usr/lib/systemd/system/systemd-swap.service

# Enable and start
echo "▶️  Enabling and starting service..."
systemctl daemon-reload
systemctl enable --now systemd-swap

echo "✅ Installation complete!"
systemctl status --no-pager systemd-swap

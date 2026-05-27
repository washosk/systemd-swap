#!/bin/bash
# systemd-swap standalone installer
set -e

if [ "$EUID" -ne 0 ]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

echo "📦 Installing systemd-swap..."

# Create directories
mkdir -p /usr/local/bin /etc/systemd /usr/lib/systemd/system

# Install manager script
echo "📝 Installing manager script..."
cp systemd-swap /usr/local/bin/
chmod 0755 /usr/local/bin/systemd-swap

# Install config
echo "⚙️  Installing configuration..."
cp swap.conf /etc/systemd/
chmod 0644 /etc/systemd/swap.conf

# Install systemd service
echo "🔧 Installing systemd service..."
cp systemd-swap.service /usr/lib/systemd/system/
chmod 0644 /usr/lib/systemd/system/systemd-swap.service

# Enable and start
echo "▶️  Enabling and starting service..."
systemctl daemon-reload
systemctl enable --now systemd-swap

echo "✅ Installation complete!"
systemctl status --no-pager systemd-swap

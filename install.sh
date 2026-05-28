#!/bin/bash
# systemd-swap: Simple Install Script
# This script installs the configuration, the manager script, and the systemd service.

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

# Verify local files exist
if [ ! -f "./systemd-swap" ] || [ ! -f "./swap.conf" ] || [ ! -f "./systemd-swap.service" ]; then
   echo "❌ Error: Installation files not found in the current directory."
   echo "Please run this script from the root of the systemd-swap repository."
   exit 1
fi

# 1. Create/Copy Configuration
echo "Installing /etc/systemd/swap.conf..."
mkdir -p /etc/systemd
cp -f ./swap.conf /etc/systemd/swap.conf
chmod 0644 /etc/systemd/swap.conf

# 2. Install Manager Script
echo "Installing /usr/local/bin/systemd-swap..."
mkdir -p /usr/local/bin
cp -f ./systemd-swap /usr/local/bin/systemd-swap
chmod 0755 /usr/local/bin/systemd-swap

# 3. Install Systemd Service
echo "Installing systemd service..."
mkdir -p /usr/lib/systemd/system
cp -f ./systemd-swap.service /usr/lib/systemd/system/systemd-swap.service
chmod 0644 /usr/lib/systemd/system/systemd-swap.service

# 4. Enable and Start
echo "Starting systemd-swap..."
systemctl daemon-reload
systemctl enable --now systemd-swap

echo "Done! Swap file is active."
swapon --show

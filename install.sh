#!/bin/bash
# systemd-swap: Extreme Simple Install Script
# This script installs the configuration, the manager script, and the systemd service.

set -e

# 1. Create Configuration
echo "Creating /etc/systemd/swap.conf..."
sudo tee /etc/systemd/swap.conf > /dev/null <<EOF
# systemd-swap configuration
SWAP_FILE="/swapfile"
SWAP_SIZE="2G"
SWAP_PRIO=50
EOF

# 2. Create the Manager Script
echo "Creating /usr/local/bin/systemd-swap..."
sudo tee /usr/local/bin/systemd-swap > /dev/null <<'EOF'
#!/bin/bash
set -e
CONFIG_FILE="/etc/systemd/swap.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"
SWAP_FILE="${SWAP_FILE:-/swapfile}"
SWAP_SIZE="${SWAP_SIZE:-2G}"
SWAP_PRIO="${SWAP_PRIO:-50}"

start() {
    if [ ! -f "$SWAP_FILE" ]; then
        echo "Creating swap file $SWAP_FILE ($SWAP_SIZE)..."
        fallocate -l "$SWAP_SIZE" "$SWAP_FILE" || dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$(echo "$SWAP_SIZE" | numfmt --from=iec --to-unit=1M)
        chmod 600 "$SWAP_FILE"
        mkswap "$SWAP_FILE"
    fi
    if ! swapon --show | grep -q "^${SWAP_FILE} "; then
        swapon -p "$SWAP_PRIO" "$SWAP_FILE"
    fi
    [ -n "$NOTIFY_SOCKET" ] && systemd-notify --ready --status="Active"
}

stop() {
    if swapon --show | grep -q "^${SWAP_FILE} "; then
        swapoff "$SWAP_FILE"
    fi
}

case "$1" in
    start) start ;;
    stop) stop ;;
    *) echo "Usage: $0 {start|stop}"; exit 1 ;;
esac
EOF
sudo chmod +x /usr/local/bin/systemd-swap

# 3. Create Systemd Service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/systemd-swap.service > /dev/null <<EOF
[Unit]
Description=Manage a simple swap file

[Service]
Type=notify
ExecStart=/usr/local/bin/systemd-swap start
ExecStop=/usr/local/bin/systemd-swap stop
RemainAfterExit=yes
CapabilityBoundingSet=CAP_SYS_ADMIN
ProtectSystem=full
ProtectHome=read-only

[Install]
WantedBy=multi-user.target
EOF

# 4. Enable and Start
echo "Starting systemd-swap..."
sudo systemctl daemon-reload
sudo systemctl enable --now systemd-swap

echo "Done! Swap file is active."
swapon --show

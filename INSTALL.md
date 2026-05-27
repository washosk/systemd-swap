# systemd-swap Installation Guide

Complete guide for installing systemd-swap across different Linux distributions and package formats.

## Table of Contents

- [Quick Start](#quick-start)
- [Package Managers](#package-managers)
- [Distribution-Specific](#distribution-specific)
- [Manual Installation](#manual-installation)
- [Container Installation](#container-installation)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Debian/Ubuntu
```bash
sudo apt update
sudo apt install ./systemd-swap_1.0.0-1_amd64.deb
sudo systemctl start systemd-swap
```

### Red Hat/Fedora/CentOS
```bash
sudo dnf install ./systemd-swap-1.0.0-1.x86_64.rpm
sudo systemctl start systemd-swap
```

### Arch Linux (AUR)
```bash
yay -S systemd-swap
sudo systemctl start systemd-swap
```

### macOS (Homebrew)
```bash
brew tap washosk/systemd-swap
brew install systemd-swap
```

### Snap (Linux universal)
```bash
sudo snap install systemd-swap
```

---

## Package Managers

### APT (Debian/Ubuntu)

**Option 1: Install from file**
```bash
# Download the .deb package
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap_1.0.0-1_amd64.deb

# Install
sudo apt install -y ./systemd-swap_1.0.0-1_amd64.deb
```

**Option 2: Add PPA (if available)**
```bash
sudo add-apt-repository ppa:washosk/systemd-swap
sudo apt update
sudo apt install systemd-swap
```

**Verification**
```bash
systemctl status systemd-swap
swapon --show
```

**Uninstall**
```bash
sudo apt remove systemd-swap
sudo apt purge systemd-swap  # Also removes config files
```

---

### DNF/YUM (Red Hat/Fedora/CentOS)

**Option 1: Install from file**
```bash
# Download the .rpm package
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-1.x86_64.rpm

# Install with dnf (Fedora)
sudo dnf install ./systemd-swap-1.0.0-1.x86_64.rpm

# Or with yum (CentOS 7)
sudo yum install ./systemd-swap-1.0.0-1.x86_64.rpm
```

**Option 2: Add YUM repository**
```bash
sudo tee /etc/yum.repos.d/washosk.repo <<EOF
[washosk]
name=washosk systemd-swap
baseurl=https://repo.example.com/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.example.com/pubkey.gpg
EOF

sudo dnf install systemd-swap
```

**Verification**
```bash
systemctl status systemd-swap
swapon --show
```

**Uninstall**
```bash
sudo dnf remove systemd-swap
```

---

### Snap (Linux-agnostic)

**Installation**
```bash
# Stable channel
sudo snap install systemd-swap

# Edge channel (development)
sudo snap install --edge systemd-swap

# From local file
sudo snap install --dangerous systemd-swap_1.0.0_*.snap
```

**Permissions**
```bash
# Grant necessary interfaces
sudo snap connect systemd-swap:system-files
```

**Verification**
```bash
snap info systemd-swap
snap services systemd-swap
```

**Uninstall**
```bash
sudo snap remove systemd-swap
```

**Update**
```bash
# Automatic updates enabled by default
# Manual update:
sudo snap refresh systemd-swap
```

---

### Linuxbrew (Linux only)

⚠️ **Important:** Homebrew on macOS is **NOT supported** because macOS does not use systemd.

For **Linux users** with Linuxbrew:

**Add tap**
```bash
brew tap washosk/systemd-swap
```

**Install**
```bash
brew install systemd-swap
```

**Verification**
```bash
brew info systemd-swap
which systemd-swap
```

**Update**
```bash
brew upgrade systemd-swap
```

**Uninstall**
```bash
brew uninstall systemd-swap
```

---

### AUR (Arch Linux)

**Using yay**
```bash
yay -S systemd-swap
```

**Using makepkg**
```bash
git clone https://aur.archlinux.org/systemd-swap.git
cd systemd-swap
makepkg -si
```

---

## Distribution-Specific

### Ubuntu 22.04 LTS
```bash
sudo apt update
sudo apt install -y ./systemd-swap_1.0.0-1_amd64.deb
sudo systemctl enable --now systemd-swap
```

### Debian 12 (Bookworm)
```bash
sudo apt install -y ./systemd-swap_1.0.0-1_amd64.deb
sudo systemctl enable --now systemd-swap
```

### Fedora 38+
```bash
sudo dnf install -y ./systemd-swap-1.0.0-1.x86_64.rpm
sudo systemctl enable --now systemd-swap
```

### CentOS 7
```bash
sudo yum install -y ./systemd-swap-1.0.0-1.x86_64.rpm
sudo systemctl enable --now systemd-swap
```

### Alpine Linux
```bash
# Install from source (Alpine doesn't have pre-built packages yet)
apk add --no-cache bash util-linux

sudo cp systemd-swap /usr/local/bin/
sudo chmod 755 /usr/local/bin/systemd-swap
```

---

## Manual Installation

### From tar.gz

**Download**
```bash
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-linux-amd64.tar.gz
tar xzf systemd-swap-1.0.0-linux-amd64.tar.gz
cd systemd-swap-1.0.0
```

**Install using provided script**
```bash
sudo bash install-standalone.sh
```

**Or manual installation**
```bash
# Copy files
sudo cp usr/local/bin/systemd-swap /usr/local/bin/
sudo cp etc/systemd/swap.conf /etc/systemd/
sudo cp usr/lib/systemd/system/systemd-swap.service /usr/lib/systemd/system/

# Fix permissions
sudo chmod 755 /usr/local/bin/systemd-swap
sudo chmod 644 /etc/systemd/swap.conf
sudo chmod 644 /usr/lib/systemd/system/systemd-swap.service

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable --now systemd-swap
```

---

### From GitHub Source

**Clone and install**
```bash
git clone https://github.com/washosk/systemd-swap.git
cd systemd-swap

# Make and install
make prepare
sudo bash scripts/install-standalone.sh
```

**Build packages**
```bash
# Debian
make deb
sudo apt install dist/systemd-swap_1.0.0-1_amd64.deb

# RPM
make rpm
sudo dnf install dist/systemd-swap-1.0.0-1.x86_64.rpm

# Docker
make docker-build
docker run systemd-swap:1.0.0
```

---

## Container Installation

### Docker

**Pull from registry**
```bash
docker pull ghcr.io/washosk/systemd-swap:1.0.0
```

**Run container**
```bash
# Interactive (for testing)
docker run -it --privileged \
  -v /tmp/swap:/swapfile \
  ghcr.io/washosk/systemd-swap:1.0.0

# Daemon mode
docker run -d --name systemd-swap --privileged \
  -v /tmp/swap:/swapfile \
  -e SWAP_SIZE=2G \
  ghcr.io/washosk/systemd-swap:1.0.0
```

### Docker Compose

**Create `docker-compose.yml`**
```yaml
version: "3.8"
services:
  systemd-swap:
    image: ghcr.io/washosk/systemd-swap:1.0.0
    privileged: true
    volumes:
      - /tmp/swap:/swapfile
    environment:
      SWAP_SIZE: 2G
      SWAP_PRIO: 50
```

**Run**
```bash
docker-compose up -d
docker-compose logs -f
```

### Kubernetes/Helm

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: systemd-swap
spec:
  containers:
  - name: swap-manager
    image: ghcr.io/washosk/systemd-swap:1.0.0
    securityContext:
      privileged: true
    volumeMounts:
    - name: swap-storage
      mountPath: /swapfile
  volumes:
  - name: swap-storage
    emptyDir:
      sizeLimit: 2Gi
```

---

## Post-Installation

### Configuration

Edit `/etc/systemd/swap.conf`:
```bash
sudo nano /etc/systemd/swap.conf
```

Available settings:
```bash
# Path to swap file (absolute path)
SWAP_FILE="/swapfile"

# Size in bytes or IEC format (512M, 1G, 2G, etc.)
SWAP_SIZE="2G"

# Swap priority (higher = preferred, range: -32768 to 32767)
SWAP_PRIO=50
```

### Enable at Boot

```bash
# Enable systemd service
sudo systemctl enable systemd-swap

# Start immediately
sudo systemctl start systemd-swap

# Verify
sudo systemctl status systemd-swap
swapon --show
```

### Disable Service

```bash
sudo systemctl disable systemd-swap
sudo systemctl stop systemd-swap
```

### View Logs

```bash
# Journal logs
sudo journalctl -u systemd-swap -n 50 -f

# System logs
sudo tail -f /var/log/syslog  # Debian/Ubuntu
sudo tail -f /var/log/messages  # Red Hat/Fedora
```

---

## Troubleshooting

### Swap not activating

**Check service status**
```bash
sudo systemctl status systemd-swap
```

**Check journalctl**
```bash
sudo journalctl -u systemd-swap -n 100
```

**Manual test**
```bash
sudo /usr/local/bin/systemd-swap start
```

### Permission denied

```bash
# Ensure script is executable
sudo chmod 755 /usr/local/bin/systemd-swap

# Ensure service has proper permissions
sudo chmod 644 /usr/lib/systemd/system/systemd-swap.service
```

### Configuration not loading

```bash
# Check config file permissions
ls -la /etc/systemd/swap.conf

# Source the config manually
source /etc/systemd/swap.conf
echo "SWAP_FILE=$SWAP_FILE"
```

### Swap file already exists

If you want to reset the swap file:
```bash
sudo swapoff /swapfile
sudo rm /swapfile
sudo systemctl restart systemd-swap
```

### Insufficient disk space

Increase available disk space or reduce `SWAP_SIZE`:
```bash
sudo nano /etc/systemd/swap.conf
# Change: SWAP_SIZE="1G"  (reduce from 2G)
sudo systemctl restart systemd-swap
```

### systemd not available

On non-systemd systems (Alpine, older distributions):
- Use the standalone script: `install-standalone.sh`
- Or install cron job to run at boot:
  ```bash
  echo "@reboot /usr/local/bin/systemd-swap start" | sudo crontab -
  ```

---

## Upgrade/Update

### From apt/dnf
```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade systemd-swap

# Red Hat/Fedora
sudo dnf upgrade systemd-swap
```

### From Snap
```bash
sudo snap refresh systemd-swap
```

### From Homebrew
```bash
brew upgrade systemd-swap
```

### From tar.gz
```bash
# Download new version
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.1/systemd-swap-1.0.1-linux-amd64.tar.gz

# Install (will overwrite)
tar xzf systemd-swap-1.0.1-linux-amd64.tar.gz
cd systemd-swap-1.0.1
sudo bash install-standalone.sh
```

---

## Uninstall

### Debian/Ubuntu
```bash
sudo apt remove systemd-swap          # Keep config
sudo apt purge systemd-swap           # Remove config too
```

### Red Hat/Fedora
```bash
sudo dnf remove systemd-swap
```

### Snap
```bash
sudo snap remove systemd-swap
```

### Homebrew
```bash
brew uninstall systemd-swap
```

### Manual removal
```bash
sudo systemctl disable --now systemd-swap
sudo rm /usr/local/bin/systemd-swap
sudo rm /etc/systemd/swap.conf
sudo rm /usr/lib/systemd/system/systemd-swap.service
sudo systemctl daemon-reload
```

---

## Support

For issues, questions, or feature requests:
- **GitHub Issues**: https://github.com/washosk/systemd-swap/issues
- **Email**: support@share.inc
- **Documentation**: https://github.com/washosk/systemd-swap/wiki

---

## License

MIT License — See LICENSE file for details

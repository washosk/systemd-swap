# systemd-swap

Simple swap file manager for systemd-based Linux systems.

## Features

✅ **Lightweight** — Minimal bash script, no heavy dependencies  
✅ **Configurable** — Easy swap file size and priority tuning  
✅ **systemd-integrated** — Native Type=notify service  
✅ **Multi-distribution** — .deb, .rpm, snap, Homebrew, tar.gz, Docker  
✅ **Cross-architecture** — Builds for amd64, arm64, and more  

## Quick Start

### Latest Download

Get the latest release directly from GitHub:

```bash
# Debian/Ubuntu (amd64)
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap_1.0.0-1_amd64.deb

# Debian/Ubuntu (arm64)
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap_1.0.0-1_arm64.deb

# Fedora/RHEL (x86_64)
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-1.x86_64.rpm

# Fedora/RHEL (aarch64)
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-1.aarch64.rpm

# Portable tarball (amd64)
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-linux-amd64.tar.gz

# Portable tarball (arm64)
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-linux-arm64.tar.gz
```

📦 **All releases:** [github.com/washosk/systemd-swap/releases](https://github.com/washosk/systemd-swap/releases)

### Install (choose one)

**Ubuntu/Debian:**
```bash
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap_1.0.0-1_amd64.deb
sudo apt install ./systemd-swap_1.0.0-1_amd64.deb
sudo systemctl start systemd-swap
```

**Fedora/RHEL:**
```bash
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-1.x86_64.rpm
sudo dnf install ./systemd-swap-1.0.0-1.x86_64.rpm
sudo systemctl start systemd-swap
```

**Snap (any Linux):**
```bash
sudo snap install systemd-swap
```

**Linuxbrew (Linux only):**
```bash
# ⚠️  Homebrew on macOS is NOT supported (macOS doesn't use systemd)
# For Linux users with Linuxbrew:
brew tap washosk/systemd-swap
brew install systemd-swap
```

**Docker:**
```bash
docker run -d --privileged --name swap \
  -v /tmp/swap:/swapfile \
  ghcr.io/washosk/systemd-swap:1.0.0
```

**Manual (any Linux):**
```bash
wget https://github.com/washosk/systemd-swap/releases/download/v1.0.0/systemd-swap-1.0.0-linux-amd64.tar.gz
tar xzf systemd-swap-1.0.0-linux-amd64.tar.gz
cd systemd-swap-1.0.0
sudo bash install-standalone.sh
```

**One-line installer (any Linux):**
```bash
curl -fsSL https://github.com/washosk/systemd-swap/releases/download/v1.0.0/install-standalone.sh | sudo bash
```

### Configure

Edit `/etc/systemd/swap.conf`:
```bash
SWAP_FILE="/swapfile"    # Swap file location
SWAP_SIZE="2G"           # Swap file size
SWAP_PRIO=50             # Swap priority (higher = preferred)
```

Then restart:
```bash
sudo systemctl restart systemd-swap
sudo swapon --show       # Verify
```

## Documentation

- **[INSTALL.md](INSTALL.md)** — Complete installation guide for all distributions
- **[BUILD.md](BUILD.md)** — Build and packaging guide for developers
- **[LICENSE](LICENSE)** — MIT License

## What's Included

```
.
├── systemd-swap              # Main script
├── swap.conf                 # Default configuration
├── systemd-swap.service      # systemd service unit
├── Makefile                  # Build system (deb, rpm, docker, snap, etc.)
├── docker/
│   ├── Dockerfile           # Container image definition
│   └── docker-compose.yml   # Docker Compose configuration
├── Formula/
│   └── systemd-swap.rb      # Homebrew formula
├── scripts/
│   ├── postinst.deb         # Debian post-install hook
│   ├── postrm.deb           # Debian post-uninstall hook
│   ├── postinst.rpm         # RPM post-install hook
│   └── postrm.rpm           # RPM post-uninstall hook
├── snapcraft.yaml           # Snap package definition
├── INSTALL.md               # User installation guide
└── BUILD.md                 # Developer build guide
```

## Distribution Methods

| Method | Command | Best For |
|--------|---------|----------|
| **Debian** | `apt install *.deb` | Ubuntu, Debian |
| **RPM** | `dnf install *.rpm` | Fedora, RHEL, CentOS |
| **Snap** | `snap install systemd-swap` | Universal Linux |
| **Linuxbrew** | `brew install systemd-swap` | Linux only |
| **Docker** | `docker run systemd-swap` | Containers, cloud |
| **tar.gz** | `tar xzf *.tar.gz && install` | Any Linux |
| **AUR** | `yay -S systemd-swap` | Arch Linux |

## Building

### Build All Packages

```bash
# Requires: make, fpm
make all

# Outputs to: dist/
ls dist/
```

### Build Specific Format

```bash
make deb           # Debian (amd64)
make deb-arm       # Debian (arm64)
make rpm           # Red Hat (x86_64)
make rpm-arm       # Red Hat (aarch64)
make targz         # Portable archive
make docker-build  # Docker image
make snap-build    # Snap package
```

### Full CI Pipeline

```bash
make ci-build      # Clean + prepare + all formats + test
```

See [BUILD.md](BUILD.md) for detailed build instructions.

## Configuration Examples

### Default (2GB swap)
```bash
SWAP_FILE="/swapfile"
SWAP_SIZE="2G"
SWAP_PRIO=50
```

### Large swap (8GB, lower priority)
```bash
SWAP_FILE="/mnt/swap"
SWAP_SIZE="8G"
SWAP_PRIO=10
```

### High-priority swap (small, preferred)
```bash
SWAP_FILE="/fast-swap"
SWAP_SIZE="512M"
SWAP_PRIO=100
```

## Service Management

```bash
# Start
sudo systemctl start systemd-swap

# Stop
sudo systemctl stop systemd-swap

# Enable at boot
sudo systemctl enable systemd-swap

# Check status
sudo systemctl status systemd-swap
journalctl -u systemd-swap -n 50 -f

# View swap
swapon --show
free -h
```

## Troubleshooting

**Swap not activating?**
```bash
sudo journalctl -u systemd-swap -n 100
```

**Need to reset?**
```bash
sudo swapoff /swapfile
sudo rm /swapfile
sudo systemctl restart systemd-swap
```

**Config not loading?**
```bash
# Check permissions
ls -la /etc/systemd/swap.conf

# Manually source
source /etc/systemd/swap.conf && echo "SWAP_FILE=$SWAP_FILE"
```

See [INSTALL.md](INSTALL.md) for more troubleshooting.

## Development

### Project Structure

```
Makefile          Multi-distribution packaging
├── .deb builds   (FPM)
├── .rpm builds   (FPM)
├── tar.gz        (archive + script)
├── Docker        (multi-stage build)
├── Snap          (snapcraft.yaml)
└── Homebrew      (formula)

scripts/          Post-install/uninstall hooks
docker/           Container definitions
Formula/          Homebrew tap formula
dist/             Build output (generated)
sources/          Staging area (generated)
```

### Building from Source

```bash
# Clone repo
git clone https://github.com/washosk/systemd-swap.git
cd systemd-swap

# Install build tools
sudo apt install make fpm  # or: brew install fpm

# Build
make all

# Install locally
sudo apt install dist/systemd-swap_1.0.0-1_amd64.deb
```

### Testing the Build

```bash
make test          # Verify artifacts exist
make ci-build      # Full pipeline with testing
```

## Requirements

- **Runtime:** `bash`, `util-linux` (swapon, swapoff), `systemd`
- **Build:** `make`, `fpm` (for native packages)
- **Optional:** `docker`, `snapcraft` (for container/snap builds)

## License

MIT License — See [LICENSE](LICENSE) for details

## Support & Contributing

- **Issues:** https://github.com/washosk/systemd-swap/issues
- **Discussions:** https://github.com/washosk/systemd-swap/discussions
- **Email:** support@share.inc

## Maintainers

- [washosk](https://github.com/washosk)

---

**Quick Links:**
- 📖 [Installation Guide](INSTALL.md)
- 🔨 [Build Guide](BUILD.md)
- 📦 [GitHub Releases](https://github.com/washosk/systemd-swap/releases)
- 🐳 [Docker Hub](https://hub.docker.com/r/washosk/systemd-swap)
- 🍺 [Homebrew Tap](https://github.com/washosk/homebrew-systemd-swap)

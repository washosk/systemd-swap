# systemd-swap Infrastructure & Packaging Setup

Complete multi-distribution packaging and CI/CD infrastructure for systemd-swap.

## 📦 What's Included

This infrastructure enables building and distributing systemd-swap across **7 different distribution methods**:

### Build Artifacts Created

```
dist/
├── systemd-swap_1.0.0-1_amd64.deb        # Debian/Ubuntu (64-bit)
├── systemd-swap_1.0.0-1_arm64.deb        # Debian/Ubuntu (ARM)
├── systemd-swap-1.0.0-1.x86_64.rpm       # Fedora/RHEL (64-bit)
├── systemd-swap-1.0.0-1.aarch64.rpm      # Fedora/RHEL (ARM)
├── systemd-swap-1.0.0-linux-amd64.tar.gz # Portable archive (64-bit)
├── systemd-swap-1.0.0-linux-arm64.tar.gz # Portable archive (ARM)
└── install-standalone.sh                  # Standalone installer
```

---

## 📁 File Structure

### Core Build System

**[Makefile](Makefile)**
- **Purpose:** Central build orchestration
- **Targets:**
  - `make all` — Build all native packages (deb, rpm, tar.gz, Docker, install script)
  - `make deb`, `make deb-arm` — Debian packages (amd64, arm64)
  - `make rpm`, `make rpm-arm` — RPM packages (x86_64, aarch64)
  - `make targz`, `make targz-arm` — Portable archives
  - `make docker-build` — Docker image
  - `make snap-build` — Snap package
  - `make install-script` — Standalone installer
  - `make ci-build` — Full CI pipeline (clean → build all → test)
  - `make test` — Verify artifacts
  - `make clean` / `make distclean` — Cleanup

---

### Container & Docker

**[docker/Dockerfile](docker/Dockerfile)**
- Multi-stage build (builder → runtime)
- Debian bookworm-slim base image
- Optimized for minimal size and security
- Configurable via environment variables (SWAP_SIZE, SWAP_PRIO)

**[docker/docker-compose.yml](docker/docker-compose.yml)**
- Development and testing environment
- Privileged container for swap management
- Volume mounts for persistent storage
- Resource limits and logging configuration

---

### Package Management

**[scripts/postinst.deb](scripts/postinst.deb)**
- Post-installation hook for Debian packages
- Creates swap directories
- Reloads systemd daemon
- Displays usage instructions

**[scripts/postrm.deb](scripts/postrm.deb)**
- Post-uninstall hook for Debian packages
- Stops and disables systemd service
- Optionally removes config on purge

**[scripts/postinst.rpm](scripts/postinst.rpm)**
- Post-installation hook for RPM packages
- Creates swap directories
- Reloads systemd daemon

**[scripts/postrm.rpm](scripts/postrm.rpm)**
- Post-uninstall hook for RPM packages
- Stops and disables systemd service

---

### Package Formulas

**[Formula/systemd-swap.rb](Formula/systemd-swap.rb)**
- Homebrew/Linuxbrew formula
- ⚠️ **Linux (Linuxbrew) only** — macOS not supported (no systemd)
- Installs script, config, and service unit
- Test suite included

**[snapcraft.yaml](snapcraft.yaml)**
- Snap package definition
- Strict confinement (requires privileged interfaces)
- Multi-architecture support (amd64, arm64)
- Auto-updates enabled
- Systemd service integration

---

### CI/CD

**[.github/workflows/build-and-release.yml](.github/workflows/build-and-release.yml)**
- GitHub Actions CI/CD pipeline
- **Triggers:**
  - On git tags (`v*`) → Build + test + release
  - On main branch push → Build only
  - On pull requests → Build + test
- **Jobs:**
  1. **build-packages** — Build all native packages
  2. **build-docker** — Build Docker image
  3. **test** — Verify package integrity
  4. **release** — Create GitHub release with artifacts
  5. **publish-docker** — Push to GitHub Container Registry
  6. **notify** — Optional Slack notifications

---

### Documentation

**[README.md](README.md)**
- Project overview
- Quick start guide
- Features and supported distributions
- Build and installation summaries

**[INSTALL.md](INSTALL.md)**
- **Comprehensive installation guide** for all distributions
- Distribution-specific instructions (apt, dnf, snap, Linuxbrew, tar.gz, Docker)
- Post-installation configuration
- Troubleshooting guide
- Update and uninstall procedures

**[BUILD.md](BUILD.md)**
- **Developer build guide**
- Prerequisites and dependencies
- Detailed explanation of all Makefile targets
- CI/CD integration examples
- Publishing to registries
- Advanced options and customization

---

### Project Files

**[LICENSE](LICENSE)**
- MIT License

**[.gitignore](.gitignore)**
- Excludes build artifacts, logs, and temporary files

---

## 🚀 Quick Start

### Build Everything

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt install make fpm ruby-dev build-essential

# Build all packages
make all

# Check outputs
ls -lh dist/
```

### Build Individual Formats

```bash
make deb          # Debian (amd64)
make rpm          # Red Hat (x86_64)
make targz        # Portable archive
make docker-build # Docker image
make snap-build   # Snap package
```

### Run Tests

```bash
make test         # Quick check
make ci-build     # Full pipeline with testing
```

---

## 📊 Distribution Methods

| Format | File | Command | Best For |
|--------|------|---------|----------|
| **Debian** | `.deb` | `apt install` | Ubuntu, Debian |
| **RPM** | `.rpm` | `dnf install` | Fedora, RHEL, CentOS |
| **Snap** | `.snap` | `snap install` | Universal Linux |
| **Linuxbrew** | Formula | `brew install` | Linux (Linuxbrew only) |
| **tar.gz** | `.tar.gz` | Extract + install | Any Linux system |
| **Docker** | OCI image | `docker run` | Containers, cloud |
| **AUR** | PKGBUILD | `yay -S` | Arch Linux |

---

## 🔄 CI/CD Workflow

### Automatic (on git tag)

```bash
# 1. Create release tag
git tag v1.0.0
git push origin v1.0.0

# 2. GitHub Actions automatically:
#    - Builds all packages
#    - Runs tests
#    - Creates GitHub release
#    - Pushes Docker image to GHCR
#    - Notifies on completion
```

### Manual Build

```bash
make ci-build
```

---

## 🔧 Customization

### Update Version

Edit `Makefile`:
```makefile
PKG_VERSION := 1.0.1  # Update version
PKG_RELEASE := 1      # Reset release number
```

### Change Package Metadata

Edit `Makefile` variables:
- `PKG_VENDOR` — Organization name
- `PKG_MAINTAINER` — Contact email
- `PKG_DESCRIPTION` — Short description
- `WEB_URL` — Project website

### Customize Installation Hooks

Edit post-install/uninstall scripts:
- `scripts/postinst.deb` — Debian post-install
- `scripts/postrm.deb` — Debian post-uninstall
- `scripts/postinst.rpm` — RPM post-install
- `scripts/postrm.rpm` — RPM post-uninstall

### Modify Docker Image

Edit `docker/Dockerfile`:
- Change base image (Alpine, Distroless, etc.)
- Add runtime dependencies
- Customize entrypoint

---

## 📋 Prerequisites

### For Building Packages

**Required:**
- `make` (build-essential on Ubuntu/Debian)
- `bash` ≥ 4.0
- `tar`, `gzip`

**For native packages (.deb, .rpm):**
- `fpm` (Effecting Package Manager)
  ```bash
  sudo gem install fpm
  ```

**For Docker images:**
- `docker` or `podman`
- Docker daemon running

**For Snap packages:**
- `snapcraft`
  ```bash
  sudo snap install snapcraft --classic
  ```

### Optional

- `git` — For version control and tagging
- `gh` (GitHub CLI) — For uploading releases
- `docker-compose` — For testing containers

---

## 📚 Documentation Map

1. **[README.md](README.md)** ← Start here (overview)
2. **[INSTALL.md](INSTALL.md)** ← User installation guide
3. **[BUILD.md](BUILD.md)** ← Developer build guide
4. **[INFRASTRUCTURE.md](INFRASTRUCTURE.md)** ← This file (architecture overview)

---

## 🐛 Troubleshooting

### FPM not found
```bash
sudo gem install fpm
```

### Permission denied
```bash
chmod +x systemd-swap scripts/*.deb scripts/*.rpm
```

### Docker build fails
```bash
docker build -f docker/Dockerfile --no-cache .
```

### Snap build fails
```bash
sudo snap refresh snapcraft --classic
snapcraft --debug
```

See [INSTALL.md](INSTALL.md#troubleshooting) for more.

---

## 🔐 Security

- **Signed releases:** Configure GPG signing in GitHub Actions
- **Container scanning:** Use tools like Trivy to scan Docker images
- **Dependency checks:** Monitor FPM and package dependencies
- **SBOM:** Generate Software Bill of Materials for each release

---

## 📈 Next Steps

1. **Test locally:**
   ```bash
   make all
   ```

2. **Verify packages:**
   ```bash
   make test
   ```

3. **Push to registry:**
   ```bash
   REGISTRY_URL=ghcr.io/washosk make docker-push
   ```

4. **Create release:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

5. **Publish to registries:**
   - Snap Store: `snapcraft login && snapcraft upload *.snap`
   - AUR: Create PKGBUILD in separate repository
   - Homebrew: Push to tap repository

---

## 📝 License

MIT License — See [LICENSE](LICENSE)

---

**Created:** 2024  
**Maintained by:** washosk  
**Contact:** support@share.inc

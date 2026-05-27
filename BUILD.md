# Build & Packaging Guide

Complete guide to building and packaging systemd-swap using the provided Makefile.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Build Targets](#build-targets)
- [Distribution Methods](#distribution-methods)
- [CI/CD Integration](#cicd-integration)
- [Publishing](#publishing)
- [Advanced Options](#advanced-options)

---

## Quick Start

### Build All Packages

```bash
# Install all build dependencies
make help     # Show available targets

# Build everything (deb, rpm, tar.gz, Docker, install script)
make all

# Check outputs
ls -lh dist/
```

### Build Specific Formats

```bash
# Debian package (amd64)
make deb

# RPM package (x86_64)
make rpm

# Both architectures
make deb deb-arm rpm rpm-arm

# Tar.gz archives
make targz targz-arm

# Docker image
make docker-build

# Snap package
make snap-build
```

---

## Prerequisites

### System Requirements

**All platforms:**
- `make` (build-essential on Ubuntu/Debian)
- `bash`
- `git`

**For native packages (.deb, .rpm):**
- FPM (Effing Package Manager)
  ```bash
  # Ubuntu/Debian
  sudo apt install ruby-dev build-essential
  sudo gem install fpm

  # macOS
  brew install fpm

  # Or Docker (automated via Makefile)
  ```

**For Docker images:**
- `docker` or `podman`
- Docker daemon running

**For Snap packages:**
- `snapcraft` (snap-based)
  ```bash
  sudo snap install snapcraft --classic
  ```

**For Homebrew formula:**
- Homebrew tap repository set up
- GitHub repository access

### Optional: Docker-based builds

If you don't have dependencies installed locally, build inside a container:

```bash
# Build using Docker (all deps pre-installed)
docker run --rm -v $(pwd):/workspace -w /workspace \
  debian:bookworm-slim bash -c 'apt update && apt install -y make fpm && make all'
```

---

## Build Targets

### Preparation Targets

#### `make prepare`
Prepare all source files and directories.
```bash
make prepare
# Creates: sources/ directory with staged files
```

#### `make sources`
Create source directory structure only.
```bash
make sources
# Creates empty directories for staging
```

#### `make stage-files`
Copy source files to staging area.
```bash
make stage-files
# Copies systemd-swap, swap.conf, service files to sources/
```

#### `make clean`
Remove build artifacts (but keep dist/).
```bash
make clean
# Removes: sources/, .build/
```

#### `make distclean`
Full cleanup including dist/ directory.
```bash
make distclean
# Removes: sources/, .build/, dist/
```

---

### Package Building Targets

#### `make deb`
Build Debian package (amd64, 64-bit Intel).
```bash
make deb
# Output: dist/systemd-swap_1.0.0-1_amd64.deb
```

#### `make deb-arm`
Build Debian package (arm64, 64-bit ARM).
```bash
make deb-arm
# Output: dist/systemd-swap_1.0.0-1_arm64.deb
```

#### `make rpm`
Build RPM package (x86_64, Red Hat/Fedora).
```bash
make rpm
# Output: dist/systemd-swap-1.0.0-1.x86_64.rpm
```

#### `make rpm-arm`
Build RPM package (aarch64, 64-bit ARM).
```bash
make rpm-arm
# Output: dist/systemd-swap-1.0.0-1.aarch64.rpm
```

#### `make targz`
Build tar.gz archive (amd64).
```bash
make targz
# Output: dist/systemd-swap-1.0.0-linux-amd64.tar.gz
```

#### `make targz-arm`
Build tar.gz archive (arm64).
```bash
make targz-arm
# Output: dist/systemd-swap-1.0.0-linux-arm64.tar.gz
```

#### `make install-script`
Generate standalone installation script.
```bash
make install-script
# Output: dist/install-standalone.sh
```

---

### Container Targets

#### `make docker-build`
Build Docker image.
```bash
make docker-build
# Builds: systemd-swap:1.0.0
# Uses: docker/Dockerfile
```

#### `make docker-push`
Push Docker image to registry (requires REGISTRY_URL).
```bash
REGISTRY_URL=ghcr.io/washosk make docker-push
# Pushes to: ghcr.io/washosk/systemd-swap:1.0.0
```

#### `make snap-build`
Build Snap package.
```bash
make snap-build
# Requires: snapcraft (sudo snap install snapcraft --classic)
# Output: systemd-swap_1.0.0_*.snap
```

---

### Testing & CI Targets

#### `make test`
Verify that packages were built successfully.
```bash
make test
# Checks if all expected files exist in dist/
```

#### `make ci-build`
Full CI pipeline: clean → prepare → all formats → test.
```bash
make ci-build
# Equivalent to: make clean prepare deb deb-arm rpm rpm-arm targz targz-arm install-script docker-build test
# Output: All packages in dist/
```

#### `make release`
Prepare release (requires git tag).
```bash
git tag v1.0.0
make release
# Verifies tag exists and packages are built
```

#### `make all` (default)
Build all native packages: deb, rpm, targz, install-script, docker-build, test.
```bash
make all
# Equivalent to: make prepare deb rpm targz install-script docker-build test
```

---

## Distribution Methods

### 1. **Debian/Ubuntu (.deb)**

**Build:**
```bash
make deb        # amd64
make deb-arm    # arm64
```

**Install:**
```bash
sudo apt install dist/systemd-swap_1.0.0-1_amd64.deb
```

**Distribution:**
- Upload to: GitHub Releases, PPA, Debian repository
- Configure in: `.deb` packaging metadata (Makefile)

---

### 2. **Red Hat/Fedora/CentOS (.rpm)**

**Build:**
```bash
make rpm        # x86_64
make rpm-arm    # aarch64
```

**Install:**
```bash
sudo dnf install dist/systemd-swap-1.0.0-1.x86_64.rpm
```

**Distribution:**
- Upload to: GitHub Releases, Copr, YUM repository
- Configure in: `.rpm` packaging metadata (Makefile)

---

### 3. **Portable Archive (tar.gz)**

**Build:**
```bash
make targz      # amd64
make targz-arm  # arm64
```

**Install:**
```bash
tar xzf dist/systemd-swap-1.0.0-linux-amd64.tar.gz
cd systemd-swap-1.0.0
sudo bash install-standalone.sh
```

**Distribution:**
- Upload to: GitHub Releases, website downloads
- Works on: Any Linux system with `bash`
- No dependencies on package manager

---

### 4. **Docker/OCI Image**

**Build:**
```bash
make docker-build
```

**Run:**
```bash
docker run -it --privileged systemd-swap:1.0.0
```

**Push to registry:**
```bash
REGISTRY_URL=ghcr.io/washosk make docker-push
```

**Distribution:**
- Container registries: Docker Hub, GitHub Container Registry (GHCR), Quay.io
- Config: `docker/Dockerfile`
- Supports: Multiple architectures via multi-stage build

---

### 5. **Snap Package**

**Build:**
```bash
make snap-build
# Requires: snapcraft --classic installed
```

**Install:**
```bash
sudo snap install dist/systemd-swap_1.0.0_*.snap --dangerous
```

**Publish:**
```bash
snapcraft upload dist/systemd-swap_1.0.0_*.snap --release=stable
```

**Distribution:**
- Snap Store: https://snapcraft.io/systemd-swap
- Config: `snapcraft.yaml`
- Auto-updates: Yes
- Confinement: Strict (requires interfaces for privileges)

---

### 6. **Homebrew (macOS/Linux)**

**Formula location:**
```
Formula/systemd-swap.rb
```

**Publish:**
1. Create tap repository: `homebrew-systemd-swap`
2. Add formula to tap
3. Users install with:
   ```bash
   brew tap washosk/systemd-swap
   brew install systemd-swap
   ```

**Distribution:**
- GitHub repository (tap)
- Config: `Formula/systemd-swap.rb`
- Works on: macOS (Intel/ARM), Linux

---

### 7. **Standalone Install Script**

**Generate:**
```bash
make install-script
# Creates: dist/install-standalone.sh
```

**Usage:**
```bash
sudo bash dist/install-standalone.sh
```

**Distribution:**
- Share on website or GitHub
- No dependencies needed
- Works on any systemd-based system

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build & Package

on:
  push:
    tags:
      - 'v*'
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y make fpm
          sudo gem install fpm
      
      - name: Build all packages
        run: make ci-build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: packages
          path: dist/
      
      - name: Create Release
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@v1
        with:
          files: dist/*
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### GitLab CI Example

```yaml
stages:
  - build
  - test
  - publish

build:packages:
  stage: build
  image: debian:bookworm
  before_script:
    - apt update && apt install -y make fpm ruby-dev build-essential
    - gem install fpm
  script:
    - make ci-build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

test:artifacts:
  stage: test
  script:
    - make test

publish:release:
  stage: publish
  script:
    - echo "Publishing to GitHub Releases..."
  only:
    - tags
```

---

## Publishing

### GitHub Releases

1. **Build packages:**
   ```bash
   make ci-build
   ```

2. **Create GitHub release:**
   ```bash
   gh release create v1.0.0 \
     --title "systemd-swap 1.0.0" \
     --notes "Release notes here" \
     dist/*
   ```

3. **Verify:**
   ```bash
   gh release view v1.0.0
   ```

### Docker Registry (GHCR)

1. **Login:**
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u $USERNAME --password-stdin
   ```

2. **Push:**
   ```bash
   REGISTRY_URL=ghcr.io/washosk make docker-push
   ```

### Snap Store

1. **Create account:** https://snapcraft.io/account

2. **Login:**
   ```bash
   snapcraft login
   ```

3. **Build and upload:**
   ```bash
   make snap-build
   snapcraft upload systemd-swap_1.0.0_*.snap --release=stable
   ```

### Package Repositories

**Debian PPA (Ubuntu):**
```bash
# If using Launchpad PPA
dput ppa:yourteam/systemd-swap dist/systemd-swap_1.0.0-1_amd64.deb
```

**Copr (Fedora):**
```bash
# If using Copr
copr-cli build washosk dist/systemd-swap-1.0.0-1.x86_64.rpm
```

---

## Advanced Options

### Customize Package Metadata

Edit `Makefile` variables:
```makefile
PKG_NAME        := systemd-swap
PKG_VERSION     := 1.0.0
PKG_RELEASE     := 1
PKG_VENDOR      := systemd-swap contributors
PKG_LICENSE     := MIT
PKG_DESCRIPTION := Simple swap file manager for systemd
```

### Build for Specific Architecture

```bash
# Build only ARM packages
make deb-arm rpm-arm targz-arm

# Override architecture
FPM_DEB_OPTS="--architecture armhf" make deb
```

### Cross-compilation with Docker

```bash
# Build packages for all architectures inside Docker
docker run --rm -v $(pwd):/workspace -w /workspace \
  --platform linux/arm64 \
  debian:bookworm-slim bash -c \
  'apt update && apt install -y make fpm && make all'
```

### Custom Installation Scripts

Edit `scripts/postinst.deb`, `scripts/postinst.rpm` to customize post-installation behavior.

### Docker Image Variants

Modify `docker/Dockerfile` to use:
- Different base images (Alpine, Distroless, etc.)
- Custom entrypoints
- Additional runtime dependencies

---

## Troubleshooting

### FPM not found

```bash
# Install FPM globally
sudo gem install fpm

# Or use Docker
docker run --rm ubuntu:latest ruby -e "gem 'fpm'; require 'fpm'"
```

### Permission denied

```bash
# Make scripts executable
chmod +x systemd-swap
chmod +x scripts/*.deb scripts/*.rpm
```

### Docker image build fails

```bash
# Check Dockerfile syntax
docker build -f docker/Dockerfile .

# Build with verbose output
docker build -f docker/Dockerfile --no-cache .
```

### Snap build fails

```bash
# Update snapcraft
sudo snap refresh snapcraft --classic

# Build in debug mode
snapcraft --debug
```

---

## See Also

- [INSTALL.md](INSTALL.md) — User installation guide
- [Makefile](Makefile) — Build system
- [docker/Dockerfile](docker/Dockerfile) — Container build
- [snapcraft.yaml](snapcraft.yaml) — Snap configuration
- [Formula/systemd-swap.rb](Formula/systemd-swap.rb) — Homebrew formula


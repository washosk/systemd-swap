# Build Quick Reference

Fast lookup for common build and packaging tasks.

## Build Commands

```bash
# Build everything
make all

# Build one format
make deb              # Debian amd64
make deb-arm          # Debian arm64
make rpm              # RedHat x86_64
make rpm-arm          # RedHat aarch64
make targz            # Portable archive
make docker-build     # Docker image
make snap-build       # Snap package
make install-script   # Standalone installer

# Test and verify
make test             # Quick check
make ci-build         # Full pipeline

# Cleanup
make clean            # Remove artifacts (keep dist/)
make distclean        # Full cleanup (remove dist/)
```

## File Locations

| What | Where |
|------|-------|
| Build system | [Makefile](Makefile) |
| Debian hooks | `scripts/postinst.deb`, `scripts/postrm.deb` |
| RPM hooks | `scripts/postinst.rpm`, `scripts/postrm.rpm` |
| Docker config | `docker/Dockerfile`, `docker/docker-compose.yml` |
| Snap config | `snapcraft.yaml` |
| Homebrew | `Formula/systemd-swap.rb` |
| CI/CD | `.github/workflows/build-and-release.yml` |

## Installation Methods

```bash
# Debian/Ubuntu
sudo apt install ./dist/systemd-swap_*.deb

# Fedora/RHEL
sudo dnf install ./dist/systemd-swap-*.rpm

# Snap
sudo snap install ./dist/systemd-swap_*.snap --dangerous

# Portable (any Linux)
tar xzf dist/systemd-swap-*.tar.gz
cd systemd-swap-*/
sudo bash install-standalone.sh

# Docker
docker run -d --privileged systemd-swap:1.0.0

# Linuxbrew (Linux only)
brew tap washosk/systemd-swap
brew install systemd-swap
```

## Customize & Build

```bash
# Edit version
nano Makefile          # Change PKG_VERSION, PKG_RELEASE

# Edit post-install behavior
nano scripts/postinst.deb
nano scripts/postinst.rpm

# Edit Docker image
nano docker/Dockerfile

# Edit configuration template
nano swap.conf

# Build after changes
make distclean && make all
```

## CI/CD Triggers

```bash
# Create release (auto-builds everything)
git tag v1.0.0
git push origin v1.0.0

# View CI status
gh run list
gh run view <RUN_ID>
gh run view <RUN_ID> --log
```

## Docker Quick Start

```bash
# Build
make docker-build

# Run (development)
docker run -it --privileged systemd-swap:1.0.0

# Run daemon
docker run -d --name swap --privileged systemd-swap:1.0.0

# Compose
cd docker
docker-compose up -d
```

## Push to Registries

```bash
# Docker (GHCR)
REGISTRY_URL=ghcr.io/washosk make docker-push

# Snap
snapcraft login
snapcraft upload dist/systemd-swap_*.snap --release=stable

# GitHub Release
gh release create v1.0.0 dist/*
```

## Verify Packages

```bash
# List artifacts
ls -lh dist/

# Test integrity
make test

# Manual checks
dpkg-deb -I dist/systemd-swap_*.deb
rpm -K dist/systemd-swap-*.rpm
tar tzf dist/systemd-swap-*.tar.gz > /dev/null
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `fpm: command not found` | `sudo gem install fpm` |
| `docker: permission denied` | `sudo usermod -aG docker $USER` |
| `snapcraft: command not found` | `sudo snap install snapcraft --classic` |
| Build fails with missing files | Run `make prepare` first |
| Want to start over | `make distclean` |

## Documentation

| Document | For |
|----------|-----|
| [README.md](README.md) | Overview & features |
| [INSTALL.md](INSTALL.md) | Users: installation & troubleshooting |
| [BUILD.md](BUILD.md) | Developers: detailed build guide |
| [INFRASTRUCTURE.md](INFRASTRUCTURE.md) | Architecture & file structure |
| [QUICKREF.md](QUICKREF.md) | Quick command lookup |

## Key Files

```
systemd-swap/
├── Makefile                        # Build system
├── README.md                       # Project overview
├── INSTALL.md                      # Installation guide
├── BUILD.md                        # Build guide
├── INFRASTRUCTURE.md               # This architecture
├── systemd-swap                    # Main script
├── swap.conf                       # Config template
├── systemd-swap.service            # Systemd unit
├── LICENSE                         # MIT
├── .gitignore                      # Git config
│
├── scripts/
│   ├── postinst.deb               # Debian post-install
│   ├── postrm.deb                 # Debian post-uninstall
│   ├── postinst.rpm               # RPM post-install
│   └── postrm.rpm                 # RPM post-uninstall
│
├── docker/
│   ├── Dockerfile                 # Container image
│   └── docker-compose.yml         # Dev environment
│
├── Formula/
│   └── systemd-swap.rb            # Homebrew formula
│
├── snapcraft.yaml                 # Snap config
│
└── .github/workflows/
    └── build-and-release.yml      # CI/CD pipeline
```

## Version Bumping

```bash
# 1. Update Makefile
sed -i 's/PKG_VERSION.*/PKG_VERSION := 1.0.1/' Makefile

# 2. Test
make ci-build

# 3. Commit
git add .
git commit -m "Bump version to 1.0.1"

# 4. Tag (auto-triggers CI/CD)
git tag v1.0.1
git push origin v1.0.1
```

## Release Checklist

- [ ] Update `PKG_VERSION` in Makefile
- [ ] Test: `make ci-build`
- [ ] Verify artifacts: `ls -lh dist/`
- [ ] Commit changes
- [ ] Create git tag: `git tag v1.0.X`
- [ ] Push: `git push origin v1.0.X`
- [ ] Wait for GitHub Actions to complete
- [ ] Verify GitHub Release was created
- [ ] Publish to Snap Store (if needed)
- [ ] Update AUR (if maintaining)
- [ ] Announce release

## Environment Variables

```bash
# For Docker push
export REGISTRY_URL=ghcr.io/washosk

# For Snap publish
export SNAPCRAFT_STORE_CREDENTIALS=...

# For GitHub CLI
export GITHUB_TOKEN=...
```

---

See full docs in [BUILD.md](BUILD.md) and [INFRASTRUCTURE.md](INFRASTRUCTURE.md).

# ======================================================================
# systemd-swap — Multi-Distribution Packaging Makefile
# ----------------------------------------------------------------------
# Builds .deb, .rpm, tar.gz, Docker images, and Snap packages
# Supports multiple installation methods for Linux systems
# ======================================================================

.SILENT:
SHELL := /bin/bash
.DEFAULT_GOAL := help

# ======================================================================
# Package metadata
# ======================================================================
PKG_NAME        := systemd-swap
PKG_VERSION     := 1.0.1
PKG_RELEASE     := 1
PKG_ARCH        := amd64
PKG_ARCH_ARM    := arm64
PKG_ARCH_RPM    := x86_64
PKG_ARCH_RPM_ARM:= aarch64
PKG_VENDOR      := systemd-swap contributors
PKG_LICENSE     := MIT
PKG_DESCRIPTION := Simple swap file manager for systemd
PKG_MAINTAINER  := systemd-swap <support@share.inc>
CATEGORY        := system
WEB_URL         := https://github.com/washosk/systemd-swap

# Build directories
SOURCESDIR      := sources
OUTPUTDIR       := ./dist
BUILDDIR        := ./.build
DOCKERDIR       := ./docker

# ======================================================================
# FPM common options (for deb/rpm)
# ======================================================================
FPM_COMMON_OPTS = \
    -s dir \
    -n $(PKG_NAME) \
    -v $(PKG_VERSION) \
    --iteration $(PKG_RELEASE) \
    --vendor "$(PKG_VENDOR)" \
    --license "$(PKG_LICENSE)" \
    --description "$(PKG_DESCRIPTION)" \
    --maintainer "$(PKG_MAINTAINER)" \
    --category "$(CATEGORY)" \
    --url "$(WEB_URL)" \
    -C $(SOURCESDIR) \
    --config-files /etc/systemd/swap.conf

# ======================================================================
# Debian-specific FPM options
# ======================================================================
FPM_DEB_OPTS = $(FPM_COMMON_OPTS) \
    -t deb \
    --architecture $(PKG_ARCH) \
    --deb-no-default-config-files \
    --depends "base-files (>= 11)" \
    --after-install scripts/postinst.deb \
    --after-remove scripts/postrm.deb

# ======================================================================
# RPM-specific FPM options
# ======================================================================
FPM_RPM_OPTS = $(FPM_COMMON_OPTS) \
    -t rpm \
    --architecture $(PKG_ARCH_RPM) \
    --after-install scripts/postinst.rpm \
    --after-remove scripts/postrm.rpm

# ======================================================================
# Package file names
# ======================================================================
PKG_DEB         := $(OUTPUTDIR)/$(PKG_NAME)_$(PKG_VERSION)-$(PKG_RELEASE)_$(PKG_ARCH).deb
PKG_DEB_ARM     := $(OUTPUTDIR)/$(PKG_NAME)_$(PKG_VERSION)-$(PKG_RELEASE)_$(PKG_ARCH_ARM).deb
PKG_RPM         := $(OUTPUTDIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).$(PKG_ARCH_RPM).rpm
PKG_RPM_ARM     := $(OUTPUTDIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).$(PKG_ARCH_RPM_ARM).rpm
PKG_TARGZ       := $(OUTPUTDIR)/$(PKG_NAME)-$(PKG_VERSION)-linux-$(PKG_ARCH).tar.gz
PKG_TARGZ_ARM   := $(OUTPUTDIR)/$(PKG_NAME)-$(PKG_VERSION)-linux-$(PKG_ARCH_ARM).tar.gz
DOCKER_IMAGE    := $(PKG_NAME):$(PKG_VERSION)

# ======================================================================
# Phony targets
# ======================================================================
.PHONY: all help clean prepare sources stage-files \
        deb deb-arm rpm rpm-arm targz targz-arm \
        docker docker-build docker-push \
        snap snap-build \
        install-script install \
        test ci-build release

# ======================================================================
# help — Show available targets
# ======================================================================
help: ## Show all available targets
	@echo ""
	@echo "systemd-swap — Multi-Distribution Packaging"
	@echo "============================================"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_%-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "Metadata:"
	@echo "  Version       : $(PKG_VERSION)-$(PKG_RELEASE)"
	@echo "  Sources dir   : $(SOURCESDIR)"
	@echo "  Output dir    : $(OUTPUTDIR)"
	@echo ""

# ======================================================================
# prepare — Stage files for packaging
# ======================================================================
prepare: clean sources stage-files ## Prepare all source files
	@echo "✅ Preparation complete"

# ======================================================================
# sources — Create source directory structure
# ======================================================================
sources: ## Create source directory structure
	@echo "📂 Creating source directories..."
	mkdir -p $(SOURCESDIR)/usr/local/bin
	mkdir -p $(SOURCESDIR)/etc/systemd
	mkdir -p $(SOURCESDIR)/usr/lib/systemd/system
	mkdir -p $(SOURCESDIR)/usr/share/doc/$(PKG_NAME)

# ======================================================================
# stage-files — Copy source files to staging area
# ======================================================================
stage-files: sources ## Copy source files to staging directories
	@echo "📋 Staging source files..."
	cp -f systemd-swap $(SOURCESDIR)/usr/local/bin/
	chmod 0755 $(SOURCESDIR)/usr/local/bin/systemd-swap
	cp -f swap.conf $(SOURCESDIR)/etc/systemd/
	cp -f systemd-swap.service $(SOURCESDIR)/usr/lib/systemd/system/
	cp -f README.md $(SOURCESDIR)/usr/share/doc/$(PKG_NAME)/ 2>/dev/null || \
	  echo "# systemd-swap" > $(SOURCESDIR)/usr/share/doc/$(PKG_NAME)/README.md

# ======================================================================
# deb — Build Debian package (amd64)
# ======================================================================
deb: prepare ## Build .deb package (amd64)
	@echo "📦 Building DEB package (amd64)..."
	mkdir -p $(OUTPUTDIR)
	fpm $(FPM_DEB_OPTS) -p "$(PKG_DEB)" .
	@[ -f "$(PKG_DEB)" ] && echo "✅ DEB created: $(PKG_DEB)" || (echo "❌ DEB build failed"; exit 1)

# ======================================================================
# deb-arm — Build Debian package (arm64)
# ======================================================================
deb-arm: prepare ## Build .deb package (arm64)
	@echo "📦 Building DEB package (arm64)..."
	mkdir -p $(OUTPUTDIR)
	fpm $(FPM_DEB_OPTS) --architecture $(PKG_ARCH_ARM) -p "$(PKG_DEB_ARM)" .
	@[ -f "$(PKG_DEB_ARM)" ] && echo "✅ DEB ARM created: $(PKG_DEB_ARM)" || (echo "❌ DEB ARM build failed"; exit 1)

# ======================================================================
# rpm — Build RPM package (x86_64)
# ======================================================================
rpm: prepare ## Build .rpm package (x86_64)
	@echo "📦 Building RPM package (x86_64)..."
	mkdir -p $(OUTPUTDIR)
	fpm $(FPM_RPM_OPTS) -p "$(PKG_RPM)" .
	@[ -f "$(PKG_RPM)" ] && echo "✅ RPM created: $(PKG_RPM)" || (echo "❌ RPM build failed"; exit 1)

# ======================================================================
# rpm-arm — Build RPM package (aarch64)
# ======================================================================
rpm-arm: prepare ## Build .rpm package (aarch64)
	@echo "📦 Building RPM package (aarch64)..."
	mkdir -p $(OUTPUTDIR)
	fpm $(FPM_RPM_OPTS) --architecture $(PKG_ARCH_RPM_ARM) -p "$(PKG_RPM_ARM)" .
	@[ -f "$(PKG_RPM_ARM)" ] && echo "✅ RPM ARM created: $(PKG_RPM_ARM)" || (echo "❌ RPM ARM build failed"; exit 1)

# ======================================================================
# targz — Build tar.gz archive (amd64) with install script
# ======================================================================
targz: prepare ## Build tar.gz archive (amd64)
	@echo "📦 Building tar.gz archive (amd64)..."
	mkdir -p $(OUTPUTDIR)
	cd $(SOURCESDIR) && tar czf ../$(PKG_TARGZ) \
		--transform 's,^,$(PKG_NAME)-$(PKG_VERSION)/,' \
		usr/ etc/
	@[ -f "$(PKG_TARGZ)" ] && echo "✅ Tarball created: $(PKG_TARGZ)" || (echo "❌ Tarball build failed"; exit 1)

# ======================================================================
# targz-arm — Build tar.gz archive (arm64)
# ======================================================================
targz-arm: prepare ## Build tar.gz archive (arm64)
	@echo "📦 Building tar.gz archive (arm64)..."
	mkdir -p $(OUTPUTDIR)
	cd $(SOURCESDIR) && tar czf ../$(PKG_TARGZ_ARM) \
		--transform 's,^,$(PKG_NAME)-$(PKG_VERSION)/,' \
		usr/ etc/
	@[ -f "$(PKG_TARGZ_ARM)" ] && echo "✅ Tarball ARM created: $(PKG_TARGZ_ARM)" || (echo "❌ Tarball ARM build failed"; exit 1)

# ======================================================================
# install-script — Generate standalone install script
# ======================================================================
install-script: ## Copy standalone install script to dist/
	@echo "📝 Copying standalone install script..."
	mkdir -p $(OUTPUTDIR)
	cp install-standalone.sh $(OUTPUTDIR)/
	chmod +x $(OUTPUTDIR)/install-standalone.sh
	@echo "✅ Install script copied to $(OUTPUTDIR)/install-standalone.sh"

# ======================================================================
# docker-build — Build Docker image
# ======================================================================
docker-build: ## Build Docker image
	@echo "🐳 Building Docker image ($(DOCKER_IMAGE))..."
	docker build -t $(DOCKER_IMAGE) -f $(DOCKERDIR)/Dockerfile .
	@echo "✅ Docker image built: $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(PKG_NAME))"

# ======================================================================
# docker-push — Push Docker image to registry
# ======================================================================
docker-push: docker-build ## Push Docker image to registry (requires REGISTRY_URL env var)
	@echo "🐳 Pushing Docker image..."
	@if [ -z "$$REGISTRY_URL" ]; then \
	    echo "❌ REGISTRY_URL not set (e.g., docker.io/username, ghcr.io/owner)"; exit 1; \
	fi
	docker tag $(DOCKER_IMAGE) $$REGISTRY_URL/$(PKG_NAME):$(PKG_VERSION)
	docker push $$REGISTRY_URL/$(PKG_NAME):$(PKG_VERSION)
	@echo "✅ Image pushed to $$REGISTRY_URL/$(PKG_NAME):$(PKG_VERSION)"

# ======================================================================
# snap-build — Build Snap package
# ======================================================================
snap-build: ## Build Snap package
	@echo "📦 Building snap package..."
	@command -v snapcraft >/dev/null 2>&1 || { echo "❌ snapcraft not installed"; exit 1; }
	snapcraft
	@echo "✅ Snap package built"

# ======================================================================
# test — Run basic tests on built packages
# ======================================================================
test: ## Test if packages were built successfully
	@echo "🧪 Running tests..."
	@[ -f "$(PKG_DEB)" ] && echo "✅ DEB exists" || echo "⚠️  DEB not found"
	@[ -f "$(PKG_RPM)" ] && echo "✅ RPM exists" || echo "⚠️  RPM not found"
	@[ -f "$(PKG_TARGZ)" ] && echo "✅ TAR.GZ exists" || echo "⚠️  TAR.GZ not found"
	@[ -f "$(OUTPUTDIR)/install-standalone.sh" ] && echo "✅ Install script exists" || echo "⚠️  Install script not found"

# ======================================================================
# ci-build — CI build (all architectures & formats)
# ======================================================================
ci-build: ## Full CI build (all formats and architectures)
	@echo "🔨 Running CI build pipeline..."
	@echo "  → Building Debian packages..."
	$(MAKE) deb deb-arm
	@echo "  → Building RPM packages..."
	$(MAKE) rpm rpm-arm
	@echo "  → Building tar.gz archives..."
	$(MAKE) targz targz-arm
	@echo "  → Generating install scripts..."
	$(MAKE) install-script
	@echo "  → Building Docker image..."
	$(MAKE) docker-build
	@echo "✅ CI build complete — all artifacts in $(OUTPUTDIR)/"
	@ls -lh $(OUTPUTDIR)/

# ======================================================================
# release — Create release package (git tag required)
# ======================================================================
release: test ## Create release (run after ci-build and tagging)
	@echo "🎉 Preparing release for $(PKG_VERSION)..."
	@git describe --tags --exact-match 2>/dev/null || { echo "⚠️  Not on a git tag"; exit 1; }
	@echo "✅ Release ready — all artifacts in $(OUTPUTDIR)/"

# ======================================================================
# clean — Remove build artifacts
# ======================================================================
clean: ## Remove all build artifacts and temporary files
	@echo "🧹 Cleaning build artifacts..."
	rm -rf $(SOURCESDIR) $(BUILDDIR) .snapcraft
	rm -f *.snap
	@echo "✅ Clean complete"

# ======================================================================
# distclean — Remove all generated files including dist
# ======================================================================
distclean: clean ## Complete cleanup (includes dist directory)
	@echo "🧹 Full cleanup..."
	rm -rf $(OUTPUTDIR)
	@echo "✅ Full cleanup complete"

# ======================================================================
# all — Default: build all native packages
# ======================================================================
all: deb rpm targz install-script docker-build test ## Build all packages (default)
	@echo "✅ All packages built successfully!"
	@echo "📍 Artifacts in $(OUTPUTDIR)/"

# ======================================================================
# End of Makefile
# ======================================================================

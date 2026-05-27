# Multi-stage Dockerfile for systemd-swap
# Provides containerized swap management

# ======================================================================
# Stage 1: Builder
# ======================================================================
FROM debian:bookworm-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy source files
COPY systemd-swap .
COPY swap.conf .
COPY systemd-swap.service .

# ======================================================================
# Stage 2: Runtime (Debian)
# ======================================================================
FROM debian:bookworm-slim

LABEL maintainer="systemd-swap <support@share.inc>"
LABEL description="Simple swap file manager for systemd"
LABEL version="1.0.0"

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    systemd \
    util-linux \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /etc/systemd \
    && mkdir -p /usr/lib/systemd/system \
    && mkdir -p /var/log/systemd-swap

# Copy from builder
COPY --from=builder /build/systemd-swap /usr/local/bin/
COPY --from=builder /build/swap.conf /etc/systemd/
COPY --from=builder /build/systemd-swap.service /usr/lib/systemd/system/

# Make script executable
RUN chmod 0755 /usr/local/bin/systemd-swap \
    && chmod 0644 /etc/systemd/swap.conf \
    && chmod 0644 /usr/lib/systemd/system/systemd-swap.service

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/systemd-swap check || exit 1

# Default command: run as systemd service
ENTRYPOINT ["/usr/local/bin/systemd-swap"]
CMD ["start"]

# ======================================================================
# Alternative: Alpine Linux (minimal)
# FROM alpine:latest
#
# RUN apk add --no-cache \
#     bash \
#     util-linux \
#     openrc
#
# COPY --from=builder /build/systemd-swap /usr/local/bin/
# COPY --from=builder /build/swap.conf /etc/systemd/
# RUN chmod 0755 /usr/local/bin/systemd-swap
#
# ENTRYPOINT ["/usr/local/bin/systemd-swap"]
# CMD ["start"]
# ======================================================================

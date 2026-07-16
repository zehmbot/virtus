# syntax=docker/dockerfile:1
FROM debian:13-slim

# Goose release to install (see github.com/block/goose/releases). Format: X.Y.Z
ARG GOOSE_VERSION=1.43.0

ENV DEBIAN_FRONTEND=noninteractive \
    # Skip the interactive `goose configure` at install time.
    CONFIGURE=false \
    # No system keyring inside a container — keep secrets in a file instead.
    GOOSE_DISABLE_KEYRING=true \
    # Install the single binary somewhere already on PATH.
    GOOSE_BIN_DIR=/usr/local/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates bzip2 git ripgrep libxcb1 libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh \
      | GOOSE_VERSION="v${GOOSE_VERSION}" bash

# Per-agent state (config, sessions, memory, logs) lives under each agent's HOME,
# which we point at a subdir of this mounted volume — e.g. HOME=/opt/data/devops.
# One volume, N isolated agents (the Goose equivalent of Hermes profiles).
VOLUME ["/opt/data"]
WORKDIR /opt/data

CMD ["sleep", "infinity"]

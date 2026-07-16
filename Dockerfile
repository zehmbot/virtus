# syntax=docker/dockerfile:1
FROM debian:13-slim

# Goose release to install (see github.com/block/goose/releases). Format: X.Y.Z
ARG GOOSE_VERSION=1.43.0

ENV DEBIAN_FRONTEND=noninteractive \
    CONFIGURE=false \
    GOOSE_DISABLE_KEYRING=true \
    GOOSE_BIN_DIR=/usr/local/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates bzip2 git ripgrep libxcb1 libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh \
      | GOOSE_VERSION="v${GOOSE_VERSION}" bash

VOLUME ["/opt/data"]
WORKDIR /opt/projects

CMD ["sleep", "infinity"]

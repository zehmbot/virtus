# syntax=docker/dockerfile:1
# ─────────────────────────────────────────────────────────────
#  Virtus — Hermes Agent image
#  Installs Nous Research's Hermes Agent via the official installer.
#  Pinned to an upstream release for reproducible builds.
# ─────────────────────────────────────────────────────────────
FROM debian:13-slim

# Upstream Hermes Agent release to install (see github.com/NousResearch/hermes-agent/releases).
ARG HERMES_VERSION=v2026.7.7.2

ENV DEBIAN_FRONTEND=noninteractive \
    HERMES_HOME=/opt/data \
    HERMES_VERSION=${HERMES_VERSION} \
    PYTHONUNBUFFERED=1 \
    PATH="/root/.local/bin:/opt/hermes/bin:${PATH}"

# Runtime deps the Hermes installer/agent expects.
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates git ripgrep ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install Hermes Agent (official install script).
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# Persistent state lives here: profiles, auth.json (OAuth tokens), memory, sessions.
# Mount a host volume onto this path so logins survive restarts and rebuilds.
VOLUME ["/opt/data"]
WORKDIR /opt/data

# Attach-on-demand model: keep the container alive so we can
#   docker exec -it <container> hermes -p <profile> chat
# (We are NOT running the gateway daemon by default.)
CMD ["sleep", "infinity"]

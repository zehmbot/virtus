#!/bin/sh
# Seed the Virtus crew: one isolated Goose agent per persona.
# Runs inside the container. Idempotent - safe to re-run.
#
# Each agent gets its own HOME under $DATA_DIR, which is what isolates its
# config, secrets, sessions, memory and logs from the rest of the crew.
set -eu

CREW="${CREW:-devops frontend backend researcher}"
DATA_DIR="${DATA_DIR:-/opt/data}"
PERSONA_DIR="${PERSONA_DIR:-/opt/personas}"

for agent in $CREW; do
  cfg="$DATA_DIR/$agent/.config/goose"
  mkdir -p "$cfg"

  # Persona -> .goosehints. personas/ is the source of truth, so this is
  # re-synced every run: edit personas/<agent>.md, not .goosehints.
  if [ -f "$PERSONA_DIR/$agent.md" ]; then
    cp "$PERSONA_DIR/$agent.md" "$cfg/.goosehints"
  else
    echo "warn: no persona found for '$agent' at $PERSONA_DIR/$agent.md" >&2
  fi

  # config.yaml is created once and then left alone, so per-agent changes
  # (e.g. giving the researcher a cheaper model) survive re-seeding.
  if [ ! -f "$cfg/config.yaml" ]; then
    {
      if [ -n "${GOOSE_PROVIDER:-}" ]; then echo "GOOSE_PROVIDER: $GOOSE_PROVIDER"; fi
      if [ -n "${GOOSE_MODEL:-}" ]; then echo "GOOSE_MODEL: $GOOSE_MODEL"; fi
      cat <<'YAML'
extensions:
  memory:
    type: builtin
    name: memory
    enabled: true
    bundled: true
    timeout: 300
  developer:
    type: builtin
    name: developer
    enabled: true
    bundled: true
    timeout: 300
YAML
    } > "$cfg/config.yaml"
  fi

  echo "seeded: $agent"
done

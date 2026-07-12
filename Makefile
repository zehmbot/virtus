# Virtus — control surface for the Hermes agent crew.
# Run `make help` to list targets.

COMPOSE := docker compose
SERVICE := hermes

# The agent crew. Add or remove a name here to change which profiles get seeded.
PROFILES := devops frontend backend researcher

.DEFAULT_GOAL := help

.PHONY: help bootstrap build up down restart ps logs shell profiles seed ensure-env \
        devops frontend backend researcher chat \
        setup-devops setup-frontend setup-backend setup-researcher setup

help:
	@echo "Virtus — Hermes agent crew"
	@echo ""
	@echo "Quick start (fresh clone):"
	@echo "  make bootstrap Build image, start container, and seed all agent profiles"
	@echo ""
	@echo "Lifecycle:"
	@echo "  make build     Build the Hermes image"
	@echo "  make seed      Create missing profiles + sync personas into SOUL.md"
	@echo "  make up        Start the crew container (detached)"
	@echo "  make down      Stop and remove the container"
	@echo "  make restart   Restart the container"
	@echo "  make ps        Show container status"
	@echo "  make logs      Follow container logs"
	@echo "  make shell     Open a shell inside the container"
	@echo "  make profiles  List Hermes profiles"
	@echo ""
	@echo "Talk to an agent (interactive chat):"
	@echo "  make devops | frontend | backend | researcher"
	@echo "  make chat P=<profile>"
	@echo ""
	@echo "Authenticate an agent to a provider (interactive):"
	@echo "  make setup-devops | setup-frontend | setup-backend | setup-researcher"
	@echo "  make setup P=<profile>"

# Create .env from the template on first use so compose never chokes on a missing file.
ensure-env:
	@test -f .env || { cp .env.example .env && echo "Created .env from .env.example — fill in your keys."; }

# --- Bootstrap ---------------------------------------------------------------
# One command from a fresh clone to a ready crew.
bootstrap:
	@$(MAKE) build
	@$(MAKE) up
	@$(MAKE) seed
	@echo ""
	@echo "Virtus is ready. Authenticate an agent, then chat:"
	@echo "  make setup-devops   # log a provider in"
	@echo "  make devops         # start chatting"

# Idempotently create any missing profiles, then sync each persona into its
# SOUL.md. Personas under personas/ are the source of truth: editing a profile's
# SOUL.md directly will be overwritten on the next seed — edit personas/<name>.md.
seed: up
	@$(COMPOSE) exec -T $(SERVICE) sh -c 'for p in $(PROFILES); do hermes profile list 2>/dev/null | grep -qw "$$p" || hermes profile create "$$p"; if [ -f "/opt/personas/$$p.md" ]; then cp "/opt/personas/$$p.md" "/opt/data/profiles/$$p/SOUL.md"; fi; done'
	@echo "Seeded + personas synced: $(PROFILES)"

# --- Lifecycle ---------------------------------------------------------------
build: ensure-env
	$(COMPOSE) build

up: ensure-env
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

shell: up
	$(COMPOSE) exec $(SERVICE) bash

profiles: up
	$(COMPOSE) exec $(SERVICE) hermes profile list

# --- Talk to a specific agent ------------------------------------------------
devops frontend backend researcher: up
	$(COMPOSE) exec $(SERVICE) hermes -p $@ chat

chat: up
	@test -n "$(P)" || { echo "Usage: make chat P=<profile>"; exit 1; }
	$(COMPOSE) exec $(SERVICE) hermes -p $(P) chat

# --- Authenticate a specific agent (interactive OAuth / wizard) --------------
setup-devops setup-frontend setup-backend setup-researcher: up
	$(COMPOSE) exec $(SERVICE) hermes -p $(@:setup-%=%) setup --portal

setup: up
	@test -n "$(P)" || { echo "Usage: make setup P=<profile>"; exit 1; }
	$(COMPOSE) exec $(SERVICE) hermes -p $(P) setup --portal

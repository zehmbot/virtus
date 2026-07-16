# Virtus — control surface for the Goose agent crew.
# Run `make help` to list targets.

# Recipes need a POSIX shell, not cmd.exe.
# On Windows install Git for Windows, which provides bash.
SHELL := bash

# Git Bash/MSYS rewrites arguments that look like paths, turning
# /opt/data/devops into C:/Program Files/Git/opt/data/devops. Off for all recipes.
export MSYS_NO_PATHCONV := 1

COMPOSE := docker compose
SERVICE := goose

# The crew. To add an agent, add a name here and a personas/<name>.md.
CREW := devops frontend backend researcher

.DEFAULT_GOAL := help

.PHONY: help bootstrap up stop down seed ensure-env $(CREW)

help:
	@echo "Virtus - Goose agent crew"
	@echo ""
	@echo "  make bootstrap   Build, start and seed the crew (first run)"
	@echo "  make up          Start the container"
	@echo "  make stop        Stop the container, keeping it"
	@echo "  make down        Stop and remove the container"
	@echo "  make seed        Re-sync personas into each agent"
	@echo ""
	@echo "  make devops | frontend | backend | researcher"
	@echo "                   Chat with an agent"

# Compose reads .env, so make sure one exists before anything else.
ensure-env:
	@test -f .env || { cp .env.example .env && echo "Created .env - add an API key to it."; }

# One command from a fresh clone to a ready crew.
bootstrap: ensure-env
	@$(COMPOSE) build $(SERVICE)
	@$(MAKE) up
	@$(MAKE) seed
	@echo ""
	@echo "Virtus is ready. Add an API key to .env, then: make devops"

up: ensure-env
	@$(COMPOSE) up -d $(SERVICE)

# Everyday pause: the container stays, so `make up` picks it straight back up.
stop:
	@$(COMPOSE) stop $(SERVICE)

down:
	@$(COMPOSE) down

# personas/ is the source of truth: edit personas/<name>.md, not .goosehints.
seed: up
	@$(COMPOSE) exec -T $(SERVICE) sh /opt/scripts/seed.sh

# Chat with one agent. Its HOME is what keeps it isolated from the rest.
$(CREW): up
	@$(COMPOSE) exec -e HOME=/opt/data/$@ $(SERVICE) goose session

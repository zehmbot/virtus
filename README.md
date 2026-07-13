# Virtus

> A crew of specialized AI agents that collaborate on your projects, then move on to the next.

**Virtus** is an open-source harness for orchestrating a crew of specialized AI agents that
collaborate on real software projects. Built on [Nous Research's Hermes Agent](https://hermes-agent.nousresearch.com/),
Virtus gives you a set of persistent, role-specialized teammates that roam from project to
project, carrying their memory and skills with them. Point the crew at a workspace, ship it,
then move on to the next.

Named for the Roman ideal of *virtus* — excellence, valor, and craftsmanship.

## What is This?

Virtus turns a single Hermes Agent install into a small team. Instead of one general-purpose
assistant, you get several role-specialized teammates — such as DevOps, Frontend, Backend, and
Researcher — each with its own identity, memory, and skills.

- **Agents are stable.** Each teammate keeps who they are and what they've learned, no matter
  which project they're working on.
- **Projects come and go.** You point the crew at a project, they build it together, and when
  it's done they move on to the next one.
- **One simple setup.** The whole crew runs from a single containerized Hermes install, driven
  by a handful of straightforward commands.

The goal is simple: turn your plans into work a crew of agents can actually pick up and do.

## Quick Start

### Requirements

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** — installed and running.
- **GNU Make** — the front door for every command.
  - Windows: `winget install ezwinports.make`
  - macOS: preinstalled (or `brew install make`)
  - Linux: `sudo apt install make` (or your package manager)
- **git** — to clone the repo.

### How to use

```bash
# 1. Clone and enter the project
git clone https://github.com/zehmbot/virtus.git && cd Virtus

# 2. Build the image, start the container, and create the crew (one command)
make bootstrap

# 3. Log an agent in to a model provider (interactive; opens the setup wizard)
make setup-devops

# 4. Start working with an agent
make devops
```

`make bootstrap` is safe to re-run — it only creates what's missing. Each agent
(`devops`, `frontend`, `backend`, `researcher`) has its own identity, memory, and
login, and they share the folders you mount under `projects/` so they can
collaborate on the same codebase.

### Commands

| Command | What it does |
| --- | --- |
| `make bootstrap` | Build the image, start the container, and seed all agent profiles |
| `make up` / `make down` | Start / stop the crew container |
| `make restart` | Restart the container |
| `make ps` | Show container status |
| `make logs` | Follow container logs |
| `make build` | (Re)build the Hermes image |
| `make seed` | Create any missing profiles + sync personas into their `SOUL.md` |
| `make profiles` | List all agent profiles |
| `make shell` | Open a shell inside the container |
| `make devops` \| `frontend` \| `backend` \| `researcher` | Chat with that agent |
| `make chat P=<profile>` | Chat with any profile by name |
| `make setup-<agent>` | Log that agent in to a provider (interactive) |
| `make setup P=<profile>` | Log any profile in by name |

Run `make help` to see the full list.

## Links

- **Hermes Agent** — the agent runtime Virtus is built on: [website](https://hermes-agent.nousresearch.com/) · [GitHub](https://github.com/NousResearch/hermes-agent)
- **agency-agents** — the source of the crew's personas (MIT): [GitHub](https://github.com/msitarzewski/agency-agents)

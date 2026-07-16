# Virtus

> A crew of specialized AI agents that collaborate on your projects, then move on to the next.

**Virtus** is an open-source harness for orchestrating a crew of specialized AI agents that
collaborate on real software projects. Built on [Goose](https://github.com/block/goose),
Virtus gives you a set of persistent, role-specialized teammates that roam from project to
project, carrying their memory and skills with them. Point the crew at a workspace, ship it,
then move on to the next.

## What is This?

Virtus turns a single Goose install into a small team. Instead of one general-purpose
assistant, you get several role-specialized teammates — DevOps, Frontend, Backend, and
Researcher — each with its own identity, memory, and sessions.

- **Agents are stable.** Each teammate keeps who they are and what they've learned, no matter
  which project they're working on.
- **Projects come and go.** You point the crew at a project, they build it together, and when
  it's done they move on to the next one.
- **One simple setup.** The whole crew runs from a single container, driven by a handful of
  straightforward commands.

The goal is simple: turn your plans into work a crew of agents can actually pick up and do.

## Quick Start

### Requirements

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** — installed and running.
- **GNU Make** — the front door for every command.
  - Windows: `winget install ezwinports.make`. Make also needs **bash** to run its
    recipes (it won't work with `cmd.exe`). Install **[Git for Windows](https://git-scm.com/download/win)**,
    which provides bash, and make sure it's on your `PATH`. The `Makefile` is
    configured to use bash, so `make` then works from PowerShell or Git Bash.
  - macOS: preinstalled (or `brew install make`)
  - Linux: `sudo apt install make` (or your package manager)
- **git** — to clone the repo.
- **A model provider** — an API key, or [Ollama](https://ollama.com/) to run models locally
  for free.

### How to use

```bash
# 1. Clone and enter the project
git clone https://github.com/zehmbot/virtus.git && cd Virtus

# 2. Build the image, start the container, and create the crew (one command)
make bootstrap

# 3. Add a provider key to .env (bootstrap creates it from .env.example)
#    e.g. GOOGLE_API_KEY=... + GOOSE_PROVIDER=google and GOOSE_MODEL=...

# 4. Start working with an agent
make devops
```

`make bootstrap` is safe to re-run — it only creates what's missing.

### Commands

| Command | What it does |
| --- | --- |
| `make bootstrap` | Build the image, start the container, and seed the crew |
| `make up` / `make down` | Start / stop the crew container |
| `make seed` | Re-sync personas into each agent |
| `make devops` \| `frontend` \| `backend` \| `researcher` | Chat with that agent |

Run `make help` to see them all.

## How it works

Every agent is a Goose install with its own `HOME` under `goose-home/<agent>/`. That one
detail is what keeps them separate: each agent gets its own config, provider key, sessions,
and memory, while sharing a single container and image.

- **Personas.** `personas/<agent>.md` is the source of truth. `make seed` copies each one into
  that agent's `.goosehints`, which Goose loads at the start of every session. Edit the
  persona, not `.goosehints` — seeding overwrites it.
- **Memory.** Agents remember across sessions and restarts. Memories live in the agent's own
  directory on disk, so `make down && make up` doesn't lose them.
- **Workspaces.** Everything under `projects/` is mounted into the container and shared by the
  whole crew, so they can collaborate on the same codebase. Agents start there.
- **Providers are per-agent.** Because each agent has its own config, they don't all have to
  use the same model — your researcher can run somewhere cheap while your backend runs on
  something stronger.

To add a teammate, add a name to `CREW` in the `Makefile` and drop in a `personas/<name>.md`.

Note that the crew shares one container and runs as the same user, so this is a separation of
identity and memory, not a security sandbox.

## Links

- **Goose** — the agent runtime Virtus is built on (Apache-2.0): [docs](https://goose-docs.ai/) · [GitHub](https://github.com/block/goose)
- **agency-agents** — the source of the crew's personas (MIT): [GitHub](https://github.com/msitarzewski/agency-agents)

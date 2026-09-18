# Pentagent

> A modular, provider-agnostic AI agent for **authorized** penetration testing and offensive-security research.

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/realdivinetech/pentagent/actions/workflows/validate.yml/badge.svg)](https://github.com/realdivinetech/pentagent/actions/workflows/validate.yml)

**Pentagent** is a personal security-operations agent that plans, executes, analyzes, validates, documents, and remediates security assessments on authorized targets. It ships as **portable prompt + skills** (runtime-agnostic Markdown) with a thin adapter for **OpenCode on Kali Linux** as the first runtime.

Author: [realdivinetech](https://github.com/realdivinetech)

## Philosophy

Pentagent behaves like a senior security operator:

> **Understand → Scope → Recon → Enumerate → Hypothesize → Test → Validate → Assess Impact → Evidence → Remediate → Retest**

It never blindly runs every scanner. Every next action is chosen from what the previous evidence shows, scanner indications stay distinct from confirmed findings, and neurotic noise never replaces signal.

## What it does

- **Specialist agent team** — each a portable canonical prompt in `prompts/agents/`:

  | Agent | Role |
  |-------|------|
  | `pentagent` | Primary operator: orchestrates the engagement end to end |
  | `osint` | Passive open-source intelligence: footprint, identities, tech, relationships |
  | `evidence` | Engagement keeper: persists all target info into a per-target workspace |
  | `planner` | Engagement strategist: persistent task tree + MITRE ATT&CK kill-chain map |
  | `critic` | Validation gate: 6-stage finding ladder, dedupe, severity calibration |
  | `report-writer` | Professional, defensible reports (executive + technical, PoC + detection rules) |
  | `setup` | Provisioner: bootstraps a fresh Linux host into a ready security workstation |

- **Engagement workspace** — every target gets an isolated folder (`$PENTAGENT_ENGAGEMENTS_DIR` or `engagements/<slug>`) with `scope.md`, `deconfliction.md`, `tasks.md`, and separated `recon/ osint/ evidence/ findings/ notes/ reports/`. Nothing is lost across sessions or context trims.

- **Setup / provisioning system** — one command turns a freshly launched Linux box into a fully equipped workstation: staged installs from a data manifest, ordered fallback sources, self-healing error loop, disk-space planning, and explicit hand-off of blockers it cannot solve. See `docs/SETUP.md`.

- **Research-driven** — Pentagent verifies CVEs, tool syntax, and exploit details against NVD, Exploit-DB, Packet Storm, GitHub advisories, HackTricks, and vendor sources before acting, and records every reference with the evidence it supports.

## Repository layout

```text
Pentagent/
├── README.md
├── AGENTS.md                  # project rules + agent roster
├── prompts/                   # portable core: the agent itself
│   ├── pentagent-system.md    # primary operator prompt
│   └── agents/                # portable specialist prompts
│       ├── osint.md  evidence.md  planner.md
│       ├── critic.md  report-writer.md  setup.md
│       └── setup-manifest.yaml       # setup tool inventory (data)
├── docs/
│   ├── QUICKSTART.md  ARCHITECTURE.md  INTEGRATION.md  SETUP.md  ROADMAP.md
├── scripts/  templates/       # CI validator, host auditor, engagement scaffold
└── engagements/               # per-target workspaces (gitignored)

Local only (git-ignored, not published): .opencode/ + opencode.jsonc — the
per-machine OpenCode runtime wiring (commands, agents, skills, permissions).
Rebuild per docs/INTEGRATION.md.
```

## Quick start (OpenCode)

Full first-session walkthrough: [docs/QUICKSTART.md](docs/QUICKSTART.md).

The portable core is in this repo. The OpenCode adapter (`.opencode/`,
`opencode.jsonc`) is **local, git-ignored, and not published** — build or
restore it per `docs/INTEGRATION.md`, or copy it from an existing install:

```bash
cd Pentagent
# restore the local adapter if needed, then:
opencode
```

With the adapter in place, use the built-in commands inside the agent:

| Command | Purpose |
|---------|---------|
| `/setup [profile]` | Provision this host (profiles: `standard`, `webapp`, `netad`, `minimal`) |
| `/tool-audit` | Report installed vs. missing tools against the setup manifest |
| `/engage` | Start a new engagement workspace for a target |
| `/osint` | Run passive OSINT on an authorized target |
| `/plan` | Build/update the task tree + ATT&CK kill-chain map |
| `/critique` | Run the critic validation gate over findings |
| `/report` | Generate the professional report |
| `/research` | Live threat/vulnerability research |

## Operational scripts & templates

| Item | Purpose |
|------|---------|
| `scripts/validate.sh` | Repo consistency check (CI runs it on every push/PR) |
| `scripts/audit.sh [profile]` | Host tool audit vs. the setup manifest (`standard` default; profiles: `webapp`, `netad`, `minimal`) |
| `scripts/render-report.sh` | Render an engagement report Markdown → styled standalone HTML + A4 PDF (cover, TOC, severity chips) |
| `templates/engagement/` | Blank, copy-able engagement workspace (scope, tasks, attack-chains, findings, critique, report skeleton + stylesheet) |

## Installation policy

Pentagent **never installs software without explicit user approval** — enforced both by prompt rule and by the OpenCode adapter's command-level permissions.

One deliberate exception: the `setup` provisioner agent is authorized to install and self-heal — but it prefers user-space installs (`~/.local/bin`) where possible, defaults to **supervised mode** (operator runs each privileged step), and never instructs granting blanket `NOPASSWD:ALL`. Its elevated grants exist only inside that agent's own wiring, never in the global permission map, and destructive host operations remain blocked even for it.

## Safety model

- Scope is a hard boundary; discovered adjacent assets never expand it.
- Confirmed ≠ scanner hit. Every finding passes the critic's validation ladder before reporting.
- Destructive/system-sensitive operations (`rm -rf /`, `mkfs`, repartitioning, power-off) are denied by the adapter, including inside the elevated `setup` agent.
- Client data, credentials, and real engagement evidence are held in gitignored local directories.

## Using it with your AI tool

Pentagent is **portable knowledge, not a locked-in app**. It is a set of
self-contained prompts/skills that any AI agent can load as its operating
instructions. Two ways to use it:

**1. In the OpenCode CLI (first adapter).** Restore the local adapter
(`.opencode/`, `opencode.jsonc` — git-ignored, see `docs/INTEGRATION.md`),
run `opencode` in this folder, and drive the engagement with the built-in
commands: `/setup` (provision the host), `/engage` (open a workspace),
`/osint`, `/plan`, `/critique`, `/report`. That is the turnkey path.

**2. In any other agent runtime (Claude Code, Gemini CLI, Cursor, remote
LLM, etc.).** The portable core is not runtime-specific:

- Load `prompts/pentagent-system.md` as the session or developer/system
  instruction. A minimal start for CLI agents:
  ```bash
  # generic agent CLI example — load the prompt as the system context
  your-agent --system "$(cat prompts/pentagent-system.md)" \
             --cwd "$PWD"                                       # then chat in the repo
  ```
- Map each specialist in `prompts/agents/` (`osint`, `evidence`, `planner`,
  `critic`, `report-writer`, `setup`) to that runtime's subagent or skill
  mechanism.
- Give the agent shell access for Kali tools, keep the installation-approval
  rule, and point the evidence keeper at an engagement workspace. Exact
  steps per runtime are in `docs/INTEGRATION.md`.

The prompts make no OpenCode-specific assumptions, so the same engagement
flow (scope → recon → test → critique → report) works everywhere. In all
cases: only ever run it against **authorized** targets.

## License

Released under the [MIT License](LICENSE).

Copyright (c) 2026 Ojo Divine-favour Damilare (realdivinetech).

Anyone may use, copy, modify, merge, publish, distribute, sublicense, and sell the software, provided the copyright and permission notices are preserved. See the [LICENSE](LICENSE) file for the full terms.

Contributions are accepted under the same license — see [CONTRIBUTING](CONTRIBUTING.md).

## GitHub

This repository is public. Engagement data under `engagements/` and setup logs under `setup/` are gitignored and never pushed. Do not commit real client evidence, credentials, or tokens to this repository.